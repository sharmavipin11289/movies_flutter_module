import 'package:movies_flutter_module/core/config/secrets.dart' as secrets;

class AppConfig {
  const AppConfig({required this.tmdbApiKey});

  factory AppConfig.fromEnvironment() {
    const fromDartDefine = String.fromEnvironment('TMDB_API_KEY');
    return AppConfig(
      tmdbApiKey: fromDartDefine.isNotEmpty
          ? fromDartDefine
          : secrets.tmdbApiKey,
    );
  }

  static const String placeholderKey = 'YOUR_TMDB_API_KEY_HERE';

  final String tmdbApiKey;

  bool get hasApiKey => tmdbApiKey.isNotEmpty && tmdbApiKey != placeholderKey;
}
