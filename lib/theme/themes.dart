import 'package:app/theme/components/video_player_slider.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

abstract class Themes {
  static ThemeData light(BuildContext context) =>
      ThemeData().appOverrides(context);

  static ThemeData dark(BuildContext context) =>
      ThemeData(brightness: Brightness.dark).appOverrides(context);

  static ThemeData videoPlayer(BuildContext context) {
    return ThemeData.from(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFFD0BCFF),
        onPrimary: Colors.white,
        secondary: Colors.grey[350]!,
        secondaryContainer: Colors.black26,
        onSecondary: Colors.white,
        error: const Color(0xFFF2B8B5),
        onError: const Color(0xFF601410),
        errorContainer: const Color(0xFF8C1D18),
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerHighest: Colors.white24,
      ),
    ).videoPlayerOverrides(context);
  }
}

extension _AppOverrides on ThemeData {
  ThemeData appOverrides(BuildContext context) {
    final bool isMediumAndUp =
        Breakpoint.activeBreakpointOf(context) >= Breakpoints.medium;
    return copyWith(
      appBarTheme: appBarTheme.copyWith(
        toolbarHeight: 64,
        scrolledUnderElevation: isMediumAndUp ? 1 : 3,
        shadowColor: isMediumAndUp ? colorScheme.shadow : null,
        backgroundColor: isMediumAndUp ? colorScheme.surface : null,
        surfaceTintColor: isMediumAndUp ? colorScheme.surface : null,
        actionsPadding: const .only(right: 8),
      ),

      cardTheme: cardTheme.copyWith(
        elevation: 1,
        shadowColor: colorScheme.shadow,
        color: colorScheme.surfaceContainerLow,
        margin: .zero,
        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(12))),
      ),

      dialogTheme: dialogTheme.copyWith(
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),

      dividerTheme: dividerTheme.copyWith(
        space: 0,
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),

      drawerTheme: drawerTheme.copyWith(width: 360),

      inputDecorationTheme: inputDecorationTheme.copyWith(
        filled: true,
        border: const UnderlineInputBorder(borderSide: .none),
        focusedBorder: UnderlineInputBorder(
          borderSide: .new(width: 2, color: colorScheme.primary),
        ),
      ),

      navigationBarTheme: navigationBarTheme.copyWith(
        elevation: 3,
        height: 68,
        labelTextStyle: .fromMap({
          WidgetState.selected: textTheme.labelMedium!.copyWith(
            color: colorScheme.secondary,
          ),
          WidgetState.any: textTheme.labelMedium!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        }),
        iconTheme: .fromMap({
          WidgetState.selected: .new(color: colorScheme.onSecondaryContainer),
          WidgetState.any: .new(color: colorScheme.onSurfaceVariant),
        }),
      ),

      navigationDrawerTheme: navigationDrawerTheme.copyWith(
        backgroundColor: colorScheme.surface,
      ),

      navigationRailTheme: navigationRailTheme.copyWith(
        minWidth: 80,
        labelType: .all,
        selectedIconTheme: .new(
          size: 24,
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: .new(
          size: 24,
          color: colorScheme.onSurfaceVariant,
        ),
        selectedLabelTextStyle: textTheme.labelMedium!.copyWith(
          fontWeight: .w600,
          color: colorScheme.onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium!.copyWith(
          fontWeight: .w500,
          color: colorScheme.onSurfaceVariant,
        ),
        backgroundColor: colorScheme.surface,
      ),

      progressIndicatorTheme: progressIndicatorTheme.copyWith(
        year2023: false,
        strokeWidth: 4,
      ),

      searchBarTheme: searchBarTheme.copyWith(
        elevation: const WidgetStatePropertyAll(6),
        textCapitalization: .sentences,
        constraints: const .new(
          minWidth: 360,
          maxWidth: 720,
          minHeight: 56,
          maxHeight: 56,
        ),
      ),

      tabBarTheme: tabBarTheme.copyWith(
        splashBorderRadius: const .vertical(top: .circular(3)),
      ),

      tooltipTheme: tooltipTheme.copyWith(
        padding: const .symmetric(horizontal: 8),
        textStyle: textTheme.bodySmall!.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: const .all(.circular(4)),
        ),
      ),
    );
  }
}

extension _VideoPlayerOverrides on ThemeData {
  ThemeData videoPlayerOverrides(BuildContext context) => copyWith(
    splashColor: const .new(0x66C8C8C8),
    appBarTheme: appBarTheme.copyWith(centerTitle: false),
    sliderTheme: .new(
      // ignore: deprecated_member_use
      year2023: false,
      trackHeight: 4,
      allowedInteraction: .slideOnly,
      overlayShape: .noOverlay,
      trackShape: const VideoPlayerSliderTrackShape(),
      thumbShape: const VideoPlayerSliderThumbShape(thumbRadius: 8),
    ),
  ).appOverrides(context);
}
