import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Serves bundled assets from `UNIT_TEST_ASSETS` the way flutter_test does,
/// while recording every requested key.
///
/// [respond] can override the reply for a key: return `null` to serve the
/// file, or a future to stand in for it (completing with `null` fails the
/// load).
final class RecordingAssetChannel {
  RecordingAssetChannel._();

  /// Replaces the `flutter/assets` handler until the next install.
  factory RecordingAssetChannel.install() {
    final RecordingAssetChannel channel = RecordingAssetChannel._();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', channel._handle);
    return channel;
  }

  final List<String> requested = <String>[];
  Future<ByteData?>? Function(String key) respond = (_) => null;

  int requestsMatching(String prefix) =>
      requested.where((String key) => key.startsWith(prefix)).length;

  Future<ByteData?>? _handle(ByteData? message) {
    final String key = utf8.decode(message!.buffer.asUint8List());
    requested.add(key);
    final Future<ByteData?>? override = respond(key);
    if (override != null) {
      return override;
    }
    return serveBundledTestAsset(key);
  }
}

/// Reads [key] the way flutter_test's mockFlutterAssets does, including the
/// package-prefix fallback.
Future<ByteData?>? serveBundledTestAsset(String key) {
  final String assetFolderPath = Platform.environment['UNIT_TEST_ASSETS']!;
  final String prefix = 'packages/${Platform.environment['APP_NAME']!}/';
  File asset = File(p.join(assetFolderPath, key));
  if (!asset.existsSync()) {
    if (!key.startsWith(prefix)) {
      return null;
    }
    asset = File(p.join(assetFolderPath, key.replaceFirst(prefix, '')));
    if (!asset.existsSync()) {
      return null;
    }
  }
  return SynchronousFuture<ByteData?>(
    Uint8List.fromList(asset.readAsBytesSync()).buffer.asByteData(),
  );
}
