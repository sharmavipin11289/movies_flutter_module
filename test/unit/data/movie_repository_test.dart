import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/data/models/movie.dart';
import 'package:movies_flutter_module/data/movie_api_client.dart';
import 'package:movies_flutter_module/data/movie_repository.dart';

class MockMovieApiClient extends Mock implements MovieApiClient {}

void main() {
  late MockMovieApiClient api;
  late MovieRepository repository;

  setUp(() {
    api = MockMovieApiClient();
    repository = MovieRepository(apiClient: api);
  });

  group('getPopularMovies', () {
    test('returns the movies from the api client', () async {
      const movies = [
        Movie(id: 1, title: 'A', overview: 'a'),
        Movie(id: 2, title: 'B', overview: 'b', posterPath: '/b.jpg'),
      ];
      when(() => api.fetchPopularMovies()).thenAnswer((_) async => movies);

      final result = await repository.getPopularMovies();

      expect(result, movies);
      verify(() => api.fetchPopularMovies()).called(1);
    });

    test('lets ApiException propagate', () {
      when(() => api.fetchPopularMovies()).thenAnswer(
        (_) async => throw const ApiException('Request failed (401)'),
      );

      expect(repository.getPopularMovies(), throwsA(isA<ApiException>()));
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
