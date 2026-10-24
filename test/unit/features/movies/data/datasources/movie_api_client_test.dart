import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/config/app_config.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:movies_flutter_module/features/movies/data/datasources/movie_api_client.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(String path, Map<String, dynamic> data) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );
}

DioException _badResponse(String path, int status) {
  final options = RequestOptions(path: path);
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response<dynamic>(requestOptions: options, statusCode: status),
  );
}

void main() {
  const config = AppConfig(tmdbApiKey: 'test-key');
  const keyParams = {'api_key': 'test-key'};

  late MockDio dio;
  late MovieApiClient api;

  setUp(() {
    dio = MockDio();
    api = MovieApiClient(dio: dio, config: config);
  });

  group('fetchPopularMovies', () {
    test('returns a parsed page and sends page=1 by default', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/movie/popular',
          queryParameters: {'api_key': 'test-key', 'page': 1},
        ),
      ).thenAnswer(
        (_) async => _ok('/movie/popular', {
          'page': 1,
          'total_pages': 3,
          'results': [
            {'id': 1, 'title': 'A', 'overview': 'a', 'poster_path': '/a.jpg'},
            {'id': 2, 'title': 'B', 'overview': 'b', 'poster_path': null},
          ],
        }),
      );

      final result = await api.fetchPopularMovies();

      expect(result.movies.length, 2);
      expect(result.movies.first.title, 'A');
      expect(result.page, 1);
      expect(result.totalPages, 3);
    });

    test('sends the requested page number', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/movie/popular',
          queryParameters: {'api_key': 'test-key', 'page': 3},
        ),
      ).thenAnswer(
        (_) async => _ok('/movie/popular', {
          'page': 3,
          'total_pages': 3,
          'results': <dynamic>[],
        }),
      );

      final result = await api.fetchPopularMovies(page: 3);

      expect(result, isA<PagedMovies>());
      expect(result.page, 3);
      expect(result.hasMore, isFalse);
    });

    test('throws ApiException on a bad status code', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => throw _badResponse('/movie/popular', 401));

      expect(api.fetchPopularMovies(), throwsA(isA<ApiException>()));
    });

    test('throws ApiException when there is no network', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/movie/popular'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(api.fetchPopularMovies(), throwsA(isA<ApiException>()));
    });
  });

  group('fetchTrailerKey', () {
    test('returns the key of the first YouTube Trailer', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/movie/550/videos',
          queryParameters: keyParams,
        ),
      ).thenAnswer(
        (_) async => _ok('/movie/550/videos', {
          'results': [
            {'key': 'teaser1', 'site': 'YouTube', 'type': 'Teaser'},
            {'key': 'vimeo1', 'site': 'Vimeo', 'type': 'Trailer'},
            {'key': 'trailer1', 'site': 'YouTube', 'type': 'Trailer'},
          ],
        }),
      );

      expect(await api.fetchTrailerKey(550), 'trailer1');
    });

    test('returns null when no trailer exists', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/movie/1/videos',
          queryParameters: keyParams,
        ),
      ).thenAnswer((_) async => _ok('/movie/1/videos', {'results': []}));

      expect(await api.fetchTrailerKey(1), isNull);
    });

    test('throws ApiException on a bad status code', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => throw _badResponse('/movie/1/videos', 500));

      expect(api.fetchTrailerKey(1), throwsA(isA<ApiException>()));
    });

    test('maps a connection error to a friendly message', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/movie/popular'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        api.fetchPopularMovies(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'No connection. Please check your internet.',
          ),
        ),
      );
    });
  });
}
