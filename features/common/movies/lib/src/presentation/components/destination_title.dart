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
    final ButtonStyleButton button = _buildButton(context);
    final EdgeInsetsGeometry? buttonPadding = button
        // ignore: invalid_use_of_protected_member
        .defaultStyleOf(context)
        .padding
        ?.resolve(WidgetState.values.toSet())
        ?.resolve(Directionality.of(context));
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
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
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: buttonPadding!.vertical / 4,
                horizontal: margin.horizontal / 2,
              ),
              child: trailing,
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
    final TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!;
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
              Icons.chevron_right,
              size: titleStyle.fontSize,
              color: titleStyle.color?.withValues(alpha: .6),
            ),
        ],
      ),
    );
  }
}
