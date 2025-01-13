import 'package:core/core.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    this.primary = true,
    this.enableRedirect = false,
    this.style,
  }) : text = 'AniWay';

  const Logo.short({
    super.key,
    this.primary = true,
    this.enableRedirect = false,
    this.style,
  }) : text = 'A';

  final String text;

  final bool primary;

  final bool enableRedirect;

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
      color: primary ? ColorScheme.of(context).primary : null,
    );

    return Link(
      uri: enableRedirect ? Uri() : null,
      builder: (context, followLink) => ConditionalWrapper(
        condition: followLink != null,
        wrapper: (context, child) => MouseRegion(
          cursor: WidgetStateMouseCursor.clickable,
          child: GestureDetector(
            onTap: followLink,
            child: child,
          ),
        ),
        child: Text(
          text,
          style: effectiveStyle,
        ),
      ),
    );
  }
}
