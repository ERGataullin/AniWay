import 'package:app/theme/components/video_player_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class Themes {
  static final ThemeData light = ThemeData().appOverrides;

  static final ThemeData dark =
      ThemeData(brightness: Brightness.dark).appOverrides;

  static final ThemeData videoPlayer = ThemeData.from(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: dark.colorScheme.primary,
      onPrimary: Colors.white,
      secondary: Colors.grey.shade400,
      secondaryContainer: Colors.black26,
      onSecondary: Colors.white,
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceContainerHighest: Colors.white24,
    ),
  ).copyWith(
    splashColor: const Color(0x66C8C8C8),
    appBarTheme: const AppBarTheme(centerTitle: false),
    sliderTheme: SliderThemeData(
      // ignore: deprecated_member_use
      year2023: false,
      trackHeight: 4,
      allowedInteraction: SliderInteraction.slideOnly,
      overlayShape: SliderComponentShape.noOverlay,
      trackShape: const VideoPlayerSliderTrackShape(),
      thumbShape: const VideoPlayerSliderThumbShape(thumbRadius: 8),
    ),
  );
}

extension _AppOverrides on ThemeData {
  ThemeData get appOverrides => copyWith(
    appBarTheme: appBarTheme.copyWith(
      scrolledUnderElevation: 3,
      toolbarHeight: 64,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: brightness),
    ),
    cardTheme: cardTheme.copyWith(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    progressIndicatorTheme: progressIndicatorTheme.copyWith(year2023: false),
    dividerTheme: dividerTheme.copyWith(
      space: 0,
      thickness: 1,
      color: colorScheme.outlineVariant,
    ),
    drawerTheme: drawerTheme.copyWith(width: 360),
    inputDecorationTheme: inputDecorationTheme.copyWith(
      border: const OutlineInputBorder(),
    ),
    navigationDrawerTheme: navigationDrawerTheme.copyWith(
      backgroundColor: colorScheme.surface,
    ),
    navigationRailTheme: navigationRailTheme.copyWith(
      minWidth: 80,
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: IconThemeData(
        size: 24,
        color: colorScheme.onSecondaryContainer,
      ),
      selectedLabelTextStyle: textTheme.labelMedium!.copyWith(
        color: colorScheme.onSurface,
      ),
      unselectedIconTheme: IconThemeData(
        size: 24,
        color: colorScheme.onSurfaceVariant,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium!.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      backgroundColor: colorScheme.surface,
    ),
    searchBarTheme: searchBarTheme.copyWith(
      elevation: const WidgetStatePropertyAll(0),
      textCapitalization: TextCapitalization.sentences,
      constraints: const BoxConstraints(
        minWidth: 360,
        maxWidth: 720,
        minHeight: 56,
        maxHeight: 56,
      ),
    ),
  );
}
