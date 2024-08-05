import 'package:flutter/material.dart';

extension _AppOverrides on ThemeData {
  ThemeData get appOverrides => copyWith(
        cardTheme: cardTheme.copyWith(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: inputDecorationTheme.copyWith(
          border: const OutlineInputBorder(),
        ),
      );
}

class Themes {
  Themes._();

  static final ThemeData light = ThemeData().appOverrides;

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
  ).appOverrides;

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
    appBarTheme: const AppBarTheme(centerTitle: false),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      allowedInteraction: SliderInteraction.slideOnly,
      overlayShape: SliderComponentShape.noOverlay,
      trackShape: const _VideoPlayerSliderTrackShape(),
      thumbShape: const _VideoPlayerSliderThumbShape(
        thumbRadius: 8,
      ),
    ),
  );
}

class _VideoPlayerSliderTrackShape extends RoundedRectSliderTrackShape {
  const _VideoPlayerSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class _VideoPlayerSliderThumbShape extends RoundSliderThumbShape {
  const _VideoPlayerSliderThumbShape({
    required double thumbRadius,
  }) : super(
          enabledThumbRadius: thumbRadius,
          disabledThumbRadius: thumbRadius,
        );

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(
      context,
      center.translate(-(value - 0.5) / 0.5 * enabledThumbRadius, 0),
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
  }
}
