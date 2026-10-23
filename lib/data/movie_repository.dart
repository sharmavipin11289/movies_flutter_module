import 'package:movies_flutter_module/data/models/movie.dart';
import 'package:movies_flutter_module/data/movie_api_client.dart';

/// Single entry point for movie data. The Bloc depends on this, not on Dio.
class MovieRepository {
  MovieRepository({required this.apiClient});

  final MovieApiClient apiClient;

  Future<List<Movie>> getPopularMovies() => apiClient.fetchPopularMovies();

  /// YouTube key of the first trailer, or null if the movie has none.
  Future<String?> getTrailerKey(int movieId) =>
      apiClient.fetchTrailerKey(movieId);
}
