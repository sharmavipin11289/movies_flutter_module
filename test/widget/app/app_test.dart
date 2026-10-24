import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/app/app.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

class MockNativeBridge extends Mock implements NativeBridge {}

void main() {
  late MockMovieRepository repository;
  late MockNativeBridge bridge;

  const movies = [
    Movie(id: 1, title: 'Movie A', overview: 'Overview A'),
    Movie(id: 2, title: 'Movie B', overview: 'Overview B'),
  ];
  const firstPage = PagedMovies(movies: movies, page: 1, totalPages: 1);
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

  testWidgets('loads and shows the movies on start', (tester) async {
    when(() => repository.getPopularMovies(page: 1))
        .thenAnswer((_) async => firstPage);

    await tester.pumpWidget(
      MoviesApp(repository: repository, bridge: bridge, hasApiKey: true),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Movie A'), findsOneWidget);
    expect(find.text('Movie B'), findsOneWidget);
  });

  testWidgets('tapping a movie fetches its trailer and opens it natively', (
    tester,
  ) async {
    when(() => repository.getPopularMovies(page: 1))
        .thenAnswer((_) async => firstPage);
    when(() => repository.getTrailerKey(2)).thenAnswer((_) async => 'key2');

    await tester.pumpWidget(
      MoviesApp(repository: repository, bridge: bridge, hasApiKey: true),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Movie B'));
    await tester.pump();
    await tester.pump();

    verify(() => repository.getTrailerKey(2)).called(1);
    verify(
      () =>
          bridge.openTrailer(movieId: 2, title: 'Movie B', youtubeKey: 'key2'),
    ).called(1);
  });

  testWidgets('shows a setup message and does not call the api without a key', (
    tester,
  ) async {
    await tester.pumpWidget(
      MoviesApp(repository: repository, bridge: bridge, hasApiKey: false),
    );
    await tester.pump();

    expect(find.textContaining('TMDB API key'), findsOneWidget);
    verifyNever(() => repository.getPopularMovies(page: any(named: 'page')));
  });
}
