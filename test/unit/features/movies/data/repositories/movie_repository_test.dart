import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/datasources/movie_api_client.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';

class MockMovieApiClient extends Mock implements MovieApiClient {}

void main() {
  late MockMovieApiClient api;
  late MovieRepository repository;

  setUp(() {
    api = MockMovieApiClient();
    repository = MovieRepository(apiClient: api);
  });

  group('getPopularMovies', () {
    test('returns the page from the api client', () async {
      const page = PagedMovies(
        movies: [
          Movie(id: 1, title: 'A', overview: 'a'),
          Movie(id: 2, title: 'B', overview: 'b', posterPath: '/b.jpg'),
        ],
        page: 1,
        totalPages: 3,
      );
      when(() => api.fetchPopularMovies(page: 1)).thenAnswer((_) async => page);

      final result = await repository.getPopularMovies(page: 1);

      expect(result, page);
      verify(() => api.fetchPopularMovies(page: 1)).called(1);
    });

    test('passes the requested page to the api client', () async {
      when(() => api.fetchPopularMovies(page: 2)).thenAnswer(
        (_) async => const PagedMovies(movies: [], page: 2, totalPages: 3),
      );

      await repository.getPopularMovies(page: 2);

      verify(() => api.fetchPopularMovies(page: 2)).called(1);
    });

    test('lets ApiException propagate', () {
      when(() => api.fetchPopularMovies(page: any(named: 'page'))).thenAnswer(
        (_) async => throw const ApiException('Request failed (401)'),
      );

      expect(
        repository.getPopularMovies(page: 1),
        throwsA(isA<ApiException>()),
      );
    });
  });
  group('getTrailerKey', () {
    test('returns the key from the api client', () async {
      when(() => api.fetchTrailerKey(550)).thenAnswer((_) async => 'abc');

      expect(await repository.getTrailerKey(550), 'abc');
      verify(() => api.fetchTrailerKey(550)).called(1);
    });

    test('returns null when the movie has no trailer', () async {
      when(() => api.fetchTrailerKey(1)).thenAnswer((_) async => null);

      expect(await repository.getTrailerKey(1), isNull);
    });

    test('lets ApiException propagate', () {
      when(() => api.fetchTrailerKey(any()))
          .thenAnswer((_) async => throw const ApiException('Network error'));

      expect(repository.getTrailerKey(1), throwsA(isA<ApiException>()));
    });
  });
}
