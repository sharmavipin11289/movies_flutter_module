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
}
