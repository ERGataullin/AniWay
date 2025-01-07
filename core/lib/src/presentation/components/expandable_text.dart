import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.data, {
    super.key,
  });

  final String data;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const int _maxLinesCollapsed = 5;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          maxLines: _maxLinesCollapsed,
          textDirection: Directionality.of(context),
          text: TextSpan(text: widget.data),
        )..layout(maxWidth: constraints.maxWidth);
        final bool exceedsMaxLinesCollapsed = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSize(
              alignment: Alignment.topCenter,
              curve: Easing.standard,
              duration: Durations.medium2,
              child: Text(
                widget.data,
                key: ValueKey(_isExpanded),
                overflow: TextOverflow.fade,
                maxLines: _isExpanded ? null : _maxLinesCollapsed,
              ),
            ),
            if (exceedsMaxLinesCollapsed)
              IconButton(
                icon: AnimatedRotation(
                  curve: Easing.standard,
                  duration: Durations.medium2,
                  turns: _isExpanded ? 0.25 : -0.25,
                  child: const Icon(Icons.chevron_left),
                ),
                onPressed: () => setState(
                  () => _isExpanded = !_isExpanded,
                ),
              ),
          ],
        );
      },
    );
  }
}
