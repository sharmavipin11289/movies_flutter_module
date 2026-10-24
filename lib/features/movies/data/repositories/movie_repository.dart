import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';
import 'package:movies_flutter_module/features/movies/data/datasources/movie_api_client.dart';

/// Single entry point for movie data. The Bloc depends on this, not on Dio.
class MovieRepository {
  MovieRepository({required this.apiClient});

  final MovieApiClient apiClient;

  Future<PagedMovies> getPopularMovies({int page = 1}) =>
      apiClient.fetchPopularMovies(page: page);

  /// YouTube key of the first trailer, or null if the movie has none.
  Future<String?> getTrailerKey(int movieId) =>
      apiClient.fetchTrailerKey(movieId);
}
