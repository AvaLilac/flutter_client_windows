import 'package:flutter/foundation.dart';
import 'package:media_kit_video/media_kit_video.dart' as mkv;

mkv.VideoControllerConfiguration chatVideoControllerConfiguration() =>
    chatVideoControllerConfigurationFor(defaultTargetPlatform);

/// Decoder settings for the inline and fullscreen chat video players.
///
/// On Android, media_kit's default `auto-safe` only ever resolves to
/// `mediacodec-copy` on our libmpv, which copies every decoded frame back to
/// system memory. Asking for `mediacodec` first cut app CPU by about 40% on a
/// moto g54. mpv still falls back to the copy mode, then to software decoding,
/// for streams MediaCodec rejects (VP9 Profile 1 4:2:2 keeps playing).
mkv.VideoControllerConfiguration chatVideoControllerConfigurationFor(
  TargetPlatform platform,
) => switch (platform) {
  TargetPlatform.android => const mkv.VideoControllerConfiguration(
    hwdec: 'mediacodec,mediacodec-copy',
  ),
  _ => const mkv.VideoControllerConfiguration(),
};
