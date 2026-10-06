import 'package:media_kit/media_kit.dart';

/// Skips the initialization wait so media_kit's disposed check and the native
/// read run in one synchronous step, and a destroyed mpv handle is never read.
Future<String> getNativePlayerProperty(NativePlayer player, String key) {
  return player.getProperty(key, waitForInitialization: false);
}
