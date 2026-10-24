import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(NativeBridge.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('sends openTrailer with movieId, title and youtubeKey', () async {
    MethodCall? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = call;
      return null;
    });

    await NativeBridge().openTrailer(
      movieId: 550,
      title: 'Fight Club',
      youtubeKey: 'abc123',
    );

    expect(received?.method, 'openTrailer');
    expect(received?.arguments, {
      'movieId': 550,
      'title': 'Fight Club',
      'youtubeKey': 'abc123',
    });
  });

  test('sends a null youtubeKey when the movie has no trailer', () async {
    MethodCall? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = call;
      return null;
    });

    await NativeBridge().openTrailer(movieId: 1, title: 'No Trailer');

    expect(received?.arguments, {
      'movieId': 1,
      'title': 'No Trailer',
      'youtubeKey': null,
    });
  });

  test(
    'does not throw when there is no native side (standalone run)',
    () async {
      // No mock handler registered -> MissingPluginException internally.
      await expectLater(
        NativeBridge().openTrailer(movieId: 1, title: 't', youtubeKey: 'k'),
        completes,
      );
    },
  );
}
