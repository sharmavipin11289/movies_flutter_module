import 'package:equatable/equatable.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';

/// One page of results from a paginated TMDB list endpoint.
class PagedMovies extends Equatable {
  const PagedMovies({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  factory PagedMovies.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return PagedMovies(
      movies: results
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  final List<Movie> movies;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [movies, page, totalPages];
}
