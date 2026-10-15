import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/ui/action_menu/sidebar_peek_menu_panel.dart';
import 'package:fluxer_app/material_ui.dart';

void main() {
  group('computeSidebarPeekMenuFollowerOffset', () {
    const MediaQueryData media = MediaQueryData(size: Size(400, 800));

    test('keeps centered alignment when menu fits', () {
      final Offset offset = computeSidebarPeekMenuFollowerOffset(
        anchorCenterY: 400,
        menuHeight: 200,
        mediaQuery: media,
      );
      expect(offset, const Offset(kSidebarPeekMenuHorizontalGap, 0));
    });

    test('shifts menu down when anchor is near the top', () {
      final Offset offset = computeSidebarPeekMenuFollowerOffset(
        anchorCenterY: 40,
        menuHeight: 200,
        mediaQuery: media,
      );
      expect(offset.dy, greaterThan(0));
      final double menuTop = 40 - 100 + offset.dy;
      expect(menuTop, greaterThanOrEqualTo(kSidebarPeekMenuEdgePadding));
    });

    test('shifts menu up when anchor is near the bottom', () {
      final Offset offset = computeSidebarPeekMenuFollowerOffset(
        anchorCenterY: 760,
        menuHeight: 200,
        mediaQuery: media,
      );
      expect(offset.dy, lessThan(0));
      final double menuBottom = 760 + 100 + offset.dy;
      expect(menuBottom, lessThanOrEqualTo(800 - kSidebarPeekMenuEdgePadding));
    });
  });
}
