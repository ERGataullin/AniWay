import 'package:app/core/core.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin ThemeWMMixin<W extends ElementaryWidget, M extends ElementaryModel>
    on WidgetModel<W, M> {
  late final ValueNotifier<ThemeData> _theme;

  bool _initialized = false;

  ValueListenable<ThemeData> get theme => _theme;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (_initialized) {
      _theme.value = Theme.of(context);
    } else {
      _theme = ValueNotifier(Theme.of(context));
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }
}

class Themes {
  Themes._();

  static final ThemeData light = ThemeData(
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
    ),
  ).appOverrides;

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
    ),
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
    splashColor: const Color(0x66C8C8C8),
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

extension _AppOverrides on ThemeData {
  ThemeData get appOverrides => copyWith(
        cardTheme: cardTheme.copyWith(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        dividerTheme: dividerTheme.copyWith(
          thickness: 1,
          color: colorScheme.outlineVariant,
        ),
        inputDecorationTheme: inputDecorationTheme.copyWith(
          border: const OutlineInputBorder(),
        ),
        navigationDrawerTheme: navigationDrawerTheme.copyWith(
          elevation: 1,
          shadowColor: colorScheme.shadow,
        ),
        navigationRailTheme: navigationRailTheme.copyWith(
          labelType: NavigationRailLabelType.all,
          backgroundColor: colorScheme.surface,
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
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;

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
