import 'package:dio/dio.dart';
import 'package:movies_flutter_module/core/config/api_constants.dart';

Dio createDio() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
