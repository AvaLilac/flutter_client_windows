import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluxer_app/core/platform/fluxer_platform.dart';

const int kDesktopImageCacheMaxBytes = 100 << 20;
const int kMobileImageCacheMaxBytes = 40 << 20;
const int kAndroidSkiaResourceCacheMaxBytes = 64 << 20;

const int kNetworkImageDiskCacheMaxObjects = 5000;
const Duration kNetworkImageDiskCacheStalePeriod = Duration(days: 30);

void configureFluxerImageCache() {
  final bool isDesktop = isFluxerDesktopOs;
  PaintingBinding.instance.imageCache.maximumSizeBytes = isDesktop
      ? kDesktopImageCacheMaxBytes
      : kMobileImageCacheMaxBytes;
  CachedNetworkImageProvider.defaultCacheManager = DefaultCacheManager(
    stalePeriod: kNetworkImageDiskCacheStalePeriod,
    maxNrOfCacheObjects: kNetworkImageDiskCacheMaxObjects,
  );
}

/// Caps Skia's GPU resource cache on Android.
///
/// The engine defaults to screen pixels * 48 bytes (about 119 MiB at
/// 1080x2400). The `flutter/skia` override is sticky in the rasterizer, so
/// later viewport changes do not recompute it.
void configureFluxerGpuResourceCache() {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return;
  }
  unawaited(
    SystemChannels.skia.invokeMethod<void>(
      'Skia.setResourceCacheMaxBytes',
      kAndroidSkiaResourceCacheMaxBytes,
    ),
  );
}

void clearFluxerImageCache() {
  PaintingBinding.instance.imageCache.clear();
}
