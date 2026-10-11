import 'package:fluxer_app/core/deep_links/user_settings_deep_link.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/settings/utils/user_settings_deep_link_scope.dart';
import 'package:fluxer_app/features/settings/utils/user_settings_section_scroll.dart';
import 'package:fluxer_app/features/ui/preview/fluxer_widget_preview.dart';
import 'package:fluxer_app/features/ui/settings/fluxer_settings_heading_link_button.dart';
import 'package:fluxer_app/material_ui.dart';

/// Vertical density of the section's children.
///
/// Use [comfortable] for form fields and complex cards (the default).
/// Use [compact] for flat tile/card lists where rows should sit close together.
enum FluxerSettingsSectionDensity { comfortable, compact }

class FluxerSettingsSection extends StatelessWidget {
  const FluxerSettingsSection({
    required this.title,
    required this.children,
    super.key,
    this.description,
    this.isFirst = false,
    this.density = FluxerSettingsSectionDensity.comfortable,
    this.sectionId,
    this.titleTrailing,
    this.linkable = true,
  });

  final String title;
  final String? description;
  final bool isFirst;
  final List<Widget> children;
  final FluxerSettingsSectionDensity density;
  final String? sectionId;
  final Widget? titleTrailing;
  final bool linkable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final layout = context.layout;

    final childGap = switch (density) {
      FluxerSettingsSectionDensity.comfortable => layout.s8,
      FluxerSettingsSectionDensity.compact => layout.s2,
    };

    final UserSettingsDeepLinkScope? linkScope =
        UserSettingsDeepLinkScope.maybeOf(context);
    final String? sectionLinkHref = sectionId == null || linkScope == null
        ? null
        : userSettingsSectionDeepLinkHref(
            sectionId: sectionId!,
            tab: linkScope.settingsTab,
            isTouchPrimary: linkScope.isTouchPrimary,
            pageSection: linkScope.pageSection,
            linkable: linkable,
          );
    final Widget? sectionLinkButton = sectionLinkHref == null
        ? null
        : FluxerSettingsHeadingLinkButton(href: sectionLinkHref);
    final Widget? headerTrailing = switch ((sectionLinkButton, titleTrailing)) {
      (null, null) => null,
      (final Widget link, null) => link,
      (null, final Widget trailing) => trailing,
      (final Widget link, final Widget trailing) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          link,
          SizedBox(width: layout.s1),
          trailing,
        ],
      ),
    };

    return KeyedSubtree(
      key: sectionId == null
          ? null
          : UserSettingsSectionScrollKeys.keyFor(sectionId!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFirst) ...[
            Divider(color: colors.borderColor),
            SizedBox(height: layout.s8),
          ],
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: textStyles.heading.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              ?headerTrailing,
            ],
          ),
          if (description != null) ...[
            SizedBox(height: layout.s1),
            Text(
              description!,
              style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ],
          SizedBox(height: layout.s4),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: childGap),
          ],
          SizedBox(height: layout.s8),
        ],
      ),
    );
  }
}

@FluxerWidgetPreview(name: 'Default', group: 'FluxerSettingsSection')
Widget fluxerSettingsSectionPreview() {
  return const FluxerSettingsSection(
    title: 'Connections',
    description: 'Control who can send you friend requests and direct messages',
    isFirst: true,
    children: [Text('Subsection content goes here')],
  );
}

@FluxerWidgetPreview(name: 'Compact', group: 'FluxerSettingsSection')
Widget fluxerSettingsSectionCompactPreview() {
  return const FluxerSettingsSection(
    title: 'Blocked Users',
    description:
        "Blocked users can't send you friend requests or message you "
        'directly.',
    isFirst: true,
    density: FluxerSettingsSectionDensity.compact,
    children: [Text('Row 1'), Text('Row 2'), Text('Row 3')],
  );
}
