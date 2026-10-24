import 'package:flutter/material.dart';
import 'package:movies_flutter_module/app/app.dart';
import 'package:movies_flutter_module/core/config/app_config.dart';
import 'package:movies_flutter_module/core/network/dio_client.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/data/datasources/movie_api_client.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final repository = MovieRepository(
    apiClient: MovieApiClient(dio: createDio(), config: config),
  );

  runApp(
    MoviesApp(
      repository: repository,
      bridge: NativeBridge(),
      hasApiKey: config.hasApiKey,
    ),
  );
}
