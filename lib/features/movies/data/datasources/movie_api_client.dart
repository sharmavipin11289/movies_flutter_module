import 'package:dio/dio.dart';
import 'package:movies_flutter_module/core/config/app_config.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';

class MovieApiClient {
  MovieApiClient({required this.dio, required this.config});

  final Dio dio;
  final AppConfig config;

  Future<PagedMovies> fetchPopularMovies({int page = 1}) async {
    final json = await _get('/movie/popular', queryParameters: {'page': page});
    return PagedMovies.fromJson(json);
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

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {'api_key': config.tmdbApiKey, ...queryParameters},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty response');
      }
      return data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw ApiException(
        status != null ? 'Request failed ($status)' : _networkMessage(e.type),
      );
    }
  }

  String _networkMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return 'No connection. Please check your internet.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
