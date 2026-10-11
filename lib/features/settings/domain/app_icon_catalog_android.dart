import 'package:fluxer_app/core/build/app_build_config.dart';
import 'package:fluxer_app/features/settings/domain/app_icon_choice.dart';
import 'package:fluxer_app/features/settings/domain/app_icon_preview_assets.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';

const String kAndroidGreyscaleAlternateIconName = 'greyscale';
const String kAndroidRainbowAlternateIconName = 'rainbow';
const String kAndroidChromaticAberrationAlternateIconName =
    'chromatic_aberration';
const String kAndroidDefaultBrutalistAlternateIconName = 'default_brutalist';
const String kAndroidGreyscaleBrutalistAlternateIconName =
    'greyscale_brutalist';
const String kAndroidCanaryBrutalistAlternateIconName =
    'default_canary_brutalist';

AppIconChoice _androidDefaultBrutalistAppIconChoice() {
  if (AppBuildConfig.isCanary) {
    return AppIconChoice(
      alternateIconName: kAndroidCanaryBrutalistAlternateIconName,
      previewAssetPath: AppIconPreviewAssets.androidCanaryBrutalist,
      label: (FluxerLocalizations l10n) => l10n.appIconOptionDefaultBrutalist,
    );
  }
  return AppIconChoice(
    alternateIconName: kAndroidDefaultBrutalistAlternateIconName,
    previewAssetPath: AppIconPreviewAssets.androidDefaultBrutalist,
    label: (FluxerLocalizations l10n) => l10n.appIconOptionDefaultBrutalist,
  );
}

List<AppIconChoice> androidAppIconChoiceCatalog() {
  return [
    AppIconChoice(
      alternateIconName: null,
      previewAssetPath: appIconPreviewAndroidDefault(),
      label: (FluxerLocalizations l10n) => l10n.appIconOptionDefault,
    ),
    AppIconChoice(
      alternateIconName: kAndroidGreyscaleAlternateIconName,
      previewAssetPath: AppIconPreviewAssets.androidGreyscale,
      label: (FluxerLocalizations l10n) => l10n.appIconOptionGreyscale,
    ),
    AppIconChoice(
      alternateIconName: kAndroidRainbowAlternateIconName,
      previewAssetPath: AppIconPreviewAssets.androidRainbow,
      label: (FluxerLocalizations l10n) => l10n.appIconOptionRainbow,
    ),
    AppIconChoice(
      alternateIconName: kAndroidChromaticAberrationAlternateIconName,
      previewAssetPath: AppIconPreviewAssets.androidChromaticAberration,
      label: (FluxerLocalizations l10n) =>
          l10n.appIconOptionChromaticAberration,
    ),
    _androidDefaultBrutalistAppIconChoice(),
    AppIconChoice(
      alternateIconName: kAndroidGreyscaleBrutalistAlternateIconName,
      previewAssetPath: AppIconPreviewAssets.androidGreyscaleBrutalist,
      label: (FluxerLocalizations l10n) => l10n.appIconOptionGreyscaleBrutalist,
    ),
  ];
}
