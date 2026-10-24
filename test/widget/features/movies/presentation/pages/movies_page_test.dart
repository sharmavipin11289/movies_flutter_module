import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/pages/movies_page.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_card.dart';

class MockMoviesBloc extends MockBloc<MoviesEvent, MoviesState>
    implements MoviesBloc {}

void main() {
  late MockMoviesBloc bloc;

  const movies = [
    Movie(id: 1, title: 'Movie A', overview: 'Overview A'),
    Movie(id: 2, title: 'Movie B', overview: 'Overview B'),
  ];

  setUp(() {
    bloc = MockMoviesBloc();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    ValueChanged<Movie>? onMovieTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MoviesBloc>.value(
          value: bloc,
          child: MoviesPage(onMovieTap: onMovieTap ?? (_) {}),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while loading', (tester) async {
    when(() => bloc.state).thenReturn(const MoviesLoading());

    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('shows a spinner in the initial state', (tester) async {
    when(() => bloc.state).thenReturn(const MoviesInitial());

    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a card for every movie when loaded', (tester) async {
    when(() => bloc.state).thenReturn(const MoviesLoaded(movies));

    await pumpPage(tester);

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('Movie A'), findsOneWidget);
    expect(find.text('Movie B'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows an empty message when the list is empty', (tester) async {
    when(() => bloc.state).thenReturn(const MoviesLoaded([]));

    await pumpPage(tester);

    expect(find.text('No movies found'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('shows the error message and a Retry button', (tester) async {
    when(() => bloc.state).thenReturn(const MoviesError('Network error'));

    await pumpPage(tester);

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Retry adds FetchMovies to the bloc', (tester) async {
    when(() => bloc.state).thenReturn(const MoviesError('Network error'));

    await pumpPage(tester);
    await tester.tap(find.text('Retry'));

    verify(() => bloc.add(const FetchMovies())).called(1);
  });

  testWidgets('tapping a card calls onMovieTap with that movie', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const MoviesLoaded(movies));
    Movie? tapped;

    await pumpPage(tester, onMovieTap: (m) => tapped = m);
    await tester.tap(find.text('Movie B'));

    expect(tapped, movies[1]);
  });

  group('pagination', () {
    final manyMovies = List.generate(
      30,
      (i) => Movie(id: i, title: 'Movie $i', overview: 'Overview $i'),
    );

    testWidgets('requests the next page when scrolled near the end', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(MoviesLoaded(manyMovies));

      await pumpPage(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      verify(() => bloc.add(const FetchNextPage())).called(greaterThan(0));
    });

    testWidgets('does not request more when hasReachedMax is true', (
      tester,
    ) async {
      when(() => bloc.state)
          .thenReturn(MoviesLoaded(manyMovies, hasReachedMax: true));

      await pumpPage(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      verifyNever(() => bloc.add(const FetchNextPage()));
    });

    testWidgets('does not request more while a page is loading', (
      tester,
    ) async {
      when(() => bloc.state)
          .thenReturn(MoviesLoaded(manyMovies, isLoadingMore: true));

      await pumpPage(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      verifyNever(() => bloc.add(const FetchNextPage()));
    });

    testWidgets('shows a spinner at the bottom while loading more', (
      tester,
    ) async {
      when(() => bloc.state)
          .thenReturn(const MoviesLoaded(movies, isLoadingMore: true));

      await pumpPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieCard), findsNWidgets(2));
    });

    testWidgets('shows an error row with Retry when loading more failed', (
      tester,
    ) async {
      when(() => bloc.state)
          .thenReturn(const MoviesLoaded(movies, loadMoreFailed: true));

      await pumpPage(tester);

      expect(find.text('Could not load more movies'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(MovieCard), findsNWidgets(2));
    });

    testWidgets('Retry in the footer adds FetchNextPage', (tester) async {
      when(() => bloc.state)
          .thenReturn(const MoviesLoaded(movies, loadMoreFailed: true));

      await pumpPage(tester);
      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const FetchNextPage())).called(1);
    });
  });
}
