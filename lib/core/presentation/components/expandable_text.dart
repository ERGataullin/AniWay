import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.data, {super.key});

  final String data;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const _maxLinesCollapsed = 4;

  static const _breakpoint = 6;

  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextStyle style = DefaultTextStyle.of(context).style;
        final textPainter = TextPainter(
          maxLines: _breakpoint,
          textDirection: Directionality.of(context),
          text: TextSpan(text: widget.data, style: style),
        )..layout(maxWidth: constraints.maxWidth);
        final bool exceedsBreakpoint = textPainter.didExceedMaxLines;
        textPainter.dispose();

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
                style: style,
                maxLines: switch (exceedsBreakpoint) {
                  false => null,
                  true when _isExpanded => null,
                  true => _maxLinesCollapsed,
                },
              ),
            ),
            if (exceedsBreakpoint)
              IconButton(
                icon: AnimatedRotation(
                  curve: Easing.standard,
                  duration: Durations.medium2,
                  turns: _isExpanded ? 0.25 : -0.25,
                  child: const Icon(Icons.chevron_left_outlined),
                ),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
          ],
        );
      },
    );
  }
}
