import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/core/config/api_constants.dart';
import 'package:movies_flutter_module/core/network/dio_client.dart';

void main() {
  test('createDio uses the TMDB base url and timeouts', () {
    final dio = createDio();

    expect(dio.options.baseUrl, ApiConstants.baseUrl);
    expect(dio.options.connectTimeout, isNotNull);
    expect(dio.options.receiveTimeout, isNotNull);
  });
}
