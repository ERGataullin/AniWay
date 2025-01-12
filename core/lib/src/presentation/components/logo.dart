import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    this.style,
  }) : text = 'AniWay';

  const Logo.short({
    super.key,
    this.style,
  }) : text = 'A';

  final String text;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle = switch (style) {
      null => TextTheme.of(context).displayLarge!,
      final TextStyle style => style,
    }
        .copyWith(
      fontFamily: 'Alvida',
      package: 'core',
      height: .75,
      color: ColorScheme.of(context).primary,
    );

    return Text(
      text,
      style: effectiveStyle,
    );
  }
}
