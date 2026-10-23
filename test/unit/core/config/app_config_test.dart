import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/core/config/app_config.dart';

void main() {
  group('AppConfig.hasApiKey', () {
    test('is false when the key is empty', () {
      const config = AppConfig(tmdbApiKey: '');

      expect(config.hasApiKey, isFalse);
    });

    test('is false when the key is still the placeholder', () {
      const config = AppConfig(tmdbApiKey: AppConfig.placeholderKey);

      expect(config.hasApiKey, isFalse);
    });

    test('is true for a real key', () {
      const config = AppConfig(tmdbApiKey: 'abc123');

      expect(config.hasApiKey, isTrue);
    });
  });
}
