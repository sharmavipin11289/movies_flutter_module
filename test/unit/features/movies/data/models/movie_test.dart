import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';

void main() {
  group('Movie.fromJson', () {
    test('parses a full TMDB movie object', () {
      final json = {
        'id': 550,
        'title': 'Fight Club',
        'overview': 'An insomniac office worker...',
        'poster_path': '/abc123.jpg',
        'vote_average': 8.4, // extra field, must be ignored
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.overview, 'An insomniac office worker...');
      expect(movie.posterPath, '/abc123.jpg');
    });

    test('keeps posterPath null when TMDB sends null', () {
      final movie = Movie.fromJson({
        'id': 1,
        'title': 'No Poster',
        'overview': 'x',
        'poster_path': null,
      });

      expect(movie.posterPath, isNull);
    });

    test('falls back to empty strings when title/overview are missing', () {
      final movie = Movie.fromJson({'id': 2});

      expect(movie.title, '');
      expect(movie.overview, '');
    });
  });

  group('Movie.posterUrl', () {
    test('builds the full image url', () {
      const movie = Movie(
        id: 1,
        title: 't',
        overview: 'o',
        posterPath: '/abc123.jpg',
      );

      expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/abc123.jpg');
    });

    test('is null when there is no poster', () {
      const movie = Movie(id: 1, title: 't', overview: 'o');

      expect(movie.posterUrl, isNull);
    });
  });

  group('Movie equality', () {
    test('two movies with the same values are equal', () {
      const a = Movie(id: 1, title: 't', overview: 'o', posterPath: '/p.jpg');
      const b = Movie(id: 1, title: 't', overview: 'o', posterPath: '/p.jpg');

      expect(a, equals(b));
    });
  });
}
