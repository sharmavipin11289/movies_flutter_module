import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/app/app.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

class MockNativeBridge extends Mock implements NativeBridge {}

/// Movies without posters, so the test never touches the network.
List<Movie> _movies(int from, int count) => List.generate(
  count,
  (i) => Movie(
    id: from + i,
    title: 'Movie ${from + i}',
    overview: 'Overview ${from + i}',
  ),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMovieRepository repository;
  late MockNativeBridge bridge;

  final page1 = PagedMovies(movies: _movies(0, 20), page: 1, totalPages: 2);
  final page2 = PagedMovies(movies: _movies(20, 20), page: 2, totalPages: 2);

  setUp(() {
    repository = MockMovieRepository();
    bridge = MockNativeBridge();
    when(
      () => bridge.openTrailer(
        movieId: any(named: 'movieId'),
        title: any(named: 'title'),
        youtubeKey: any(named: 'youtubeKey'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MoviesApp(repository: repository, bridge: bridge, hasApiKey: true),
    );
    await tester.pumpAndSettle();
  }

  group('movies flow', () {
    testWidgets('shows the list of movies on launch', (tester) async {
      when(() => repository.getPopularMovies(page: 1))
          .thenAnswer((_) async => page1);

      await launchApp(tester);

      expect(find.text('Popular Movies'), findsOneWidget);
      expect(find.text('Movie 0'), findsOneWidget);
      expect(find.text('Overview 0'), findsOneWidget);
      expect(find.text('Movie 1'), findsOneWidget);
    });

    testWidgets('tapping a movie sends its trailer key to native', (
      tester,
    ) async {
      when(() => repository.getPopularMovies(page: 1))
          .thenAnswer((_) async => page1);
      when(() => repository.getTrailerKey(2)).thenAnswer((_) async => 'key-2');

      await launchApp(tester);
      await tester.tap(find.text('Movie 2'));
      await tester.pumpAndSettle();

      verify(() => repository.getTrailerKey(2)).called(1);
      verify(
        () => bridge.openTrailer(
          movieId: 2,
          title: 'Movie 2',
          youtubeKey: 'key-2',
        ),
      ).called(1);
    });

    testWidgets('sends a null key when the movie has no trailer', (
      tester,
    ) async {
      when(() => repository.getPopularMovies(page: 1))
          .thenAnswer((_) async => page1);
      when(() => repository.getTrailerKey(3)).thenAnswer((_) async => null);

      await launchApp(tester);
      await tester.tap(find.text('Movie 3'));
      await tester.pumpAndSettle();

      verify(
        () =>
            bridge.openTrailer(movieId: 3, title: 'Movie 3', youtubeKey: null),
      ).called(1);
    });

    testWidgets('shows a snackbar and does not call native when the trailer '
        'request fails', (tester) async {
      when(() => repository.getPopularMovies(page: 1))
          .thenAnswer((_) async => page1);
      when(() => repository.getTrailerKey(2)).thenAnswer(
        (_) async => throw const ApiException('Trailer request failed'),
      );

      await launchApp(tester);
      await tester.tap(find.text('Movie 2'));
      // Not pumpAndSettle: the snackbar disappears after a few seconds.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Trailer request failed'), findsOneWidget);
      verifyNever(
        () => bridge.openTrailer(
          movieId: any(named: 'movieId'),
          title: any(named: 'title'),
          youtubeKey: any(named: 'youtubeKey'),
        ),
      );
    });

    testWidgets('shows an error and recovers after Retry', (tester) async {
      var calls = 0;
      when(() => repository.getPopularMovies(page: 1)).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const ApiException('No connection');
        return page1;
      });

      await launchApp(tester);

      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Movie 0'), findsOneWidget);
      expect(find.text('No connection'), findsNothing);
    });

    testWidgets('loads the next page when scrolled to the end', (tester) async {
      when(() => repository.getPopularMovies(page: 1))
          .thenAnswer((_) async => page1);
      when(() => repository.getPopularMovies(page: 2))
          .thenAnswer((_) async => page2);

      await launchApp(tester);
      await tester.scrollUntilVisible(
        find.text('Movie 25'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      verify(() => repository.getPopularMovies(page: 2)).called(1);
      expect(find.text('Movie 25'), findsOneWidget);
    });
  });
}
