import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/providers/pickers/attachment_panel_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/bottom_input_slot_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/expression_panel_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/mobile_keyboard_metrics_provider.dart';
import 'package:fluxer_app/features/chat/utils/composer/bottom_input_slot_layout.dart';
import 'package:fluxer_app/features/chat/utils/composer/composer_panel.dart';
import 'package:fluxer_app/features/shell/presentation/responsive_layout.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/gestures/expandable_sheet_gestures.dart';

class BottomInputSpacer extends ConsumerWidget {
  const BottomInputSpacer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isMobileLayout(context)) {
      return const SizedBox.shrink();
    }

    final bool isPanelOpen = isComposerPanelOpen(
      expressionPanelOpen: ref.watch(expressionPanelProvider),
      attachmentPanelOpen: ref.watch(attachmentPanelProvider),
    );
    if (isPanelOpen) {
      return _buildPanelSpacer(context, ref);
    }
    return _buildKeyboardSpacer(context, ref);
  }

  Widget _buildPanelSpacer(BuildContext context, WidgetRef ref) {
    final bool panelClosing = ref.watch(composerPanelClosingProvider);
    final double homeIndicatorInset = _homeIndicatorInset(context);
    if (panelClosing) {
      return _animatedSpacer(
        context,
        totalHeight: homeIndicatorInset,
        splitHomeIndicator: true,
      );
    }

    final BottomInputSlotState slotState = ref.watch(bottomInputSlotProvider);
    final ({double? anchoredKeyboardHeight, double fallbackKeyboardHeight})
    panelMetrics = ref.watch(
      mobileKeyboardMetricsProvider.select(
        (MobileKeyboardMetricsState metrics) => (
          anchoredKeyboardHeight: metrics.anchoredKeyboardHeight,
          fallbackKeyboardHeight: metrics.fallbackKeyboardHeight,
        ),
      ),
    );
    final double anchorHeight = inlineExpressionPanelAnchorHeight(
      anchoredKeyboardHeight: panelMetrics.anchoredKeyboardHeight,
      fallbackHeight: panelMetrics.fallbackKeyboardHeight,
    );
    final double reservedHeight = resolvePanelReservedLayoutHeight(
      slotHeight: slotState.slotHeight,
      netAnchorHeight: anchorHeight,
      grossAnchorHeight: anchorHeight,
      useExactSlotHeight: slotState.slotHeightHeld,
    );
    if (reservedHeight <= 0) {
      return const SizedBox.shrink();
    }
    return _animatedSpacer(
      context,
      totalHeight: reservedHeight,
      splitHomeIndicator: true,
    );
  }

  Widget _buildKeyboardSpacer(BuildContext context, WidgetRef ref) {
    final BottomInputSlotState slotState = ref.watch(bottomInputSlotProvider);
    final ({
      double liveKeyboardHeight,
      bool unmeasuredKeyboardReserved,
      bool isKeyboardVisible,
    })
    metrics = ref.watch(
      mobileKeyboardMetricsProvider.select(
        (MobileKeyboardMetricsState state) => (
          liveKeyboardHeight: state.liveKeyboardHeight,
          unmeasuredKeyboardReserved: state.unmeasuredKeyboardReserved,
          isKeyboardVisible: state.isKeyboardVisible,
        ),
      ),
    );
    final bool keyboardLayoutActive =
        metrics.liveKeyboardHeight > 0 ||
        metrics.unmeasuredKeyboardReserved ||
        slotState.transition != BottomInputTransition.idle ||
        slotState.slotHeightHeld;
    final double spacerHeight = _keyboardSpacerHeight(
      context,
      slotState.slotHeight,
      keyboardLayoutActive: keyboardLayoutActive,
    );
    if (spacerHeight <= 0) {
      return const SizedBox.shrink();
    }

    final double homeIndicatorInset = _homeIndicatorInset(context);
    final double viewInsetBottom = resolvedKeyboardInsetBottom(context);
    final bool trackLiveKeyboardHeight =
        metrics.isKeyboardVisible && metrics.liveKeyboardHeight > 0;
    final double paintHeight = resolveBottomInputAnimatedSpacerPaintHeight(
      spacerHeight: spacerHeight,
      viewInsetBottom: viewInsetBottom,
      homeIndicatorInset: homeIndicatorInset,
      trackLiveKeyboardHeight: trackLiveKeyboardHeight,
    );
    if (paintHeight <= 0) {
      return const SizedBox.shrink();
    }

    final bool trackInset = shouldTrackKeyboardInsetForAnimatedSpacer(
      spacerHeight: spacerHeight,
      viewInsetBottom: viewInsetBottom,
      paintHeight: paintHeight,
      trackLiveKeyboardHeight: trackLiveKeyboardHeight,
    );
    return _animatedSpacer(
      context,
      totalHeight: paintHeight,
      splitHomeIndicator: shouldSplitBottomInputSpacerHomeIndicator(
        totalHeight: paintHeight,
        spacerHeight: spacerHeight,
        homeIndicatorInset: homeIndicatorInset,
        liveKeyboardHeight: metrics.liveKeyboardHeight,
        trackLiveKeyboardHeight: trackLiveKeyboardHeight,
      ),
      isDragging: trackLiveKeyboardHeight || trackInset,
    );
  }

  double _homeIndicatorInset(BuildContext context) {
    return bottomInputHomeIndicatorInset(MediaQuery.of(context));
  }

  double _keyboardSpacerHeight(
    BuildContext context,
    double slotHeight, {
    required bool keyboardLayoutActive,
  }) {
    final double homeIndicatorInset = _homeIndicatorInset(context);
    final double inset = resolvedKeyboardInsetBottom(context);
    final double resolved = resolveKeyboardSpacerRawHeight(
      viewInsetBottom: inset,
      slotHeight: slotHeight,
      keyboardLayoutActive: keyboardLayoutActive,
    );
    if (resolved <= 0) {
      return 0;
    }
    return bottomInputKeyboardSpacerHeight(
      slotHeight: resolved,
      homeIndicatorInset: homeIndicatorInset,
    );
  }

  Widget _animatedSpacer(
    BuildContext context, {
    required double totalHeight,
    required bool splitHomeIndicator,
    bool isDragging = false,
  }) {
    final Color background = context.colors.chatInputBackground;
    final double homeIndicatorInset = _homeIndicatorInset(context);
    final ({double bodyHeight, double indicatorHeight}) split =
        splitBottomInputSpacerHeights(
          totalHeight: totalHeight,
          homeIndicatorInset: homeIndicatorInset,
          splitHomeIndicator: splitHomeIndicator,
        );
    if (split.bodyHeight <= 0 && split.indicatorHeight <= 0) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (split.bodyHeight > 0)
          expandableSheetAnimatedSize(
            context: context,
            isDragging: isDragging,
            height: split.bodyHeight,
            decoration: BoxDecoration(color: background),
            child: const SizedBox.shrink(),
          ),
        if (split.indicatorHeight > 0)
          ColoredBox(
            color: background,
            child: SizedBox(height: split.indicatorHeight),
          ),
      ],
    );
  }
}
