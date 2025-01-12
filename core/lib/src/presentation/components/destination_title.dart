import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DestinationTitle extends StatelessWidget {
  const DestinationTitle(
    this.title, {
    super.key,
    required this.margin,
    this.uri,
    this.trailing,
  });

  final EdgeInsets margin;

  final ValueListenable<String> title;

  final Uri? uri;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextTheme.of(context).titleLarge!;
    TextStyle trailingStyle = TextTheme.of(context).titleMedium!;
    trailingStyle = trailingStyle.copyWith(
      color: trailingStyle.color!.withValues(alpha: .6),
    );

    return SafeArea(
      child: Padding(
        padding: margin,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Link(
                uri: uri,
                builder: (context, followLink) => MouseRegion(
                  cursor: WidgetStateMouseCursor.clickable,
                  child: GestureDetector(
                    onTap: followLink,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title.value,
                            style: titleStyle,
                          ),
                        ),
                        if (followLink != null)
                          Icon(
                            Icons.chevron_right_outlined,
                            size: titleStyle.fontSize! * titleStyle.height!,
                            weight: titleStyle.fontWeight?.value.toDouble(),
                            color: titleStyle.color!.withValues(alpha: .6),
                            shadows: titleStyle.shadows,
                            applyTextScaling: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (trailing != null)
              DefaultTextStyle(
                style: trailingStyle,
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
