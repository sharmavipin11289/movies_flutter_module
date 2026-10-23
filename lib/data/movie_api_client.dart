import 'package:dio/dio.dart';
import 'package:movies_flutter_module/core/config/app_config.dart';
import 'package:movies_flutter_module/data/models/movie.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class MovieApiClient {
  MovieApiClient({required this.dio, required this.config});

  final Dio dio;
  final AppConfig config;

  Future<List<Movie>> fetchPopularMovies() async {
    final json = await _get('/movie/popular');
    final results = json['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the YouTube key of the first trailer, or null if none exists.
  Future<String?> fetchTrailerKey(int movieId) async {
    final json = await _get('/movie/$movieId/videos');
    final results = json['results'] as List<dynamic>? ?? [];
    for (final item in results) {
      final video = item as Map<String, dynamic>;
      if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
        return video['key'] as String?;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {'api_key': config.tmdbApiKey},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty response');
      }
      return data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw ApiException(
        status != null
            ? 'Request failed ($status)'
            : 'Network error: ${e.message ?? e.type.name}',
      );
    }
  }
}
