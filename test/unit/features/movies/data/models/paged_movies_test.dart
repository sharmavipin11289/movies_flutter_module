import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';

void main() {
  group('PagedMovies.fromJson', () {
    test('parses results, page and total_pages', () {
      final paged = PagedMovies.fromJson({
        'page': 2,
        'total_pages': 5,
        'results': [
          {'id': 1, 'title': 'A', 'overview': 'a', 'poster_path': '/a.jpg'},
        ],
      });

      expect(paged.page, 2);
      expect(paged.totalPages, 5);
      expect(paged.movies, [
        const Movie(id: 1, title: 'A', overview: 'a', posterPath: '/a.jpg'),
      ]);
    });

    test('falls back to an empty single page when fields are missing', () {
      final paged = PagedMovies.fromJson({});

      expect(paged.movies, isEmpty);
      expect(paged.page, 1);
      expect(paged.totalPages, 1);
    });
  });

  group('PagedMovies.hasMore', () {
    test('is true while page < totalPages', () {
      const paged = PagedMovies(movies: [], page: 1, totalPages: 3);
      expect(paged.hasMore, isTrue);
    });

    test('is false on the last page', () {
      const paged = PagedMovies(movies: [], page: 3, totalPages: 3);
      expect(paged.hasMore, isFalse);
    });
  });
}
