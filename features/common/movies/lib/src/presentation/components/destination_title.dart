import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DestinationTitle extends StatelessWidget {
  const DestinationTitle(
    this.data, {
    super.key,
    required this.margin,
    this.uri,
    this.trailing,
  });

  final EdgeInsets margin;

  final ValueListenable<String> data;

  final Uri? uri;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ButtonStyleButton buttonPrototype = _buildButton(context);
    final EdgeInsetsGeometry? buttonPadding = buttonPrototype
        // ignore: invalid_use_of_protected_member
        .defaultStyleOf(context)
        .padding
        ?.resolve(WidgetState.values.toSet())
        ?.resolve(Directionality.of(context));
    TextStyle trailingStyle = TextTheme.of(context).titleMedium!;
    trailingStyle = trailingStyle.copyWith(
      color: trailingStyle.color!.withValues(alpha: .6),
    );

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Link(
            uri: uri,
            builder: (context, followLink) {
              final EdgeInsets effectiveMargin = buttonPadding == null
                  ? margin
                  : EdgeInsets.symmetric(
                      horizontal:
                          (margin.horizontal - buttonPadding.horizontal) / 2,
                    );

              return Padding(
                padding: effectiveMargin,
                child: _buildButton(context, onPressed: followLink),
              );
            },
          ),
          if (trailing != null) ...[
            const Spacer(),
            DefaultTextStyle(
              style: trailingStyle,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: buttonPadding!.vertical / 4,
                  horizontal: margin.horizontal / 2,
                ),
                child: trailing,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ButtonStyleButton _buildButton(
    BuildContext context, {
    VoidCallback? onPressed,
  }) {
    final TextStyle titleStyle = TextTheme.of(context).titleLarge!;
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: data,
            builder: (context, title, ___) => Text(
              title,
              style: titleStyle,
            ),
          ),
          if (onPressed != null)
            Icon(
              Icons.chevron_right_outlined,
              applyTextScaling: true,
              size: titleStyle.fontSize,
              weight: titleStyle.fontWeight?.value.toDouble(),
              color: titleStyle.color?.withValues(alpha: .6),
            ),
        ],
      ),
    );
  }
}
