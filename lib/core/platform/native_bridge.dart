import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Talks to the host (native) app over a [MethodChannel].
///
/// The channel name must be identical in the Android and iOS host apps.
class NativeBridge {
  NativeBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'com.vipin.movies/bridge';

  final MethodChannel _channel;

  Future<void> openTrailer({
    required int movieId,
    required String title,
    String? youtubeKey,
  }) async {
    try {
      await _channel.invokeMethod<void>('openTrailer', {
        'movieId': movieId,
        'title': title,
        'youtubeKey': youtubeKey,
      });
    } on MissingPluginException {
      debugPrint('NativeBridge: no native handler for openTrailer');
    }
  }
}
