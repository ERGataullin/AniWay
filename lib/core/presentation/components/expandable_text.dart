import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.data, {super.key, this.style});

  final String data;

  final TextStyle? style;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const _maxLinesCollapsed = 4;

  static const _breakpoint = 6;

  var _isExpanded = false;

  late TextStyle _style;

  late TextPainter _painter;

  @override
  void didChangeDependencies() {
    _style = widget.style ?? DefaultTextStyle.of(context).style;
    _painter = TextPainter(
      textDirection: Directionality.of(context),
      text: TextSpan(text: widget.data, style: _style),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _painter.layout(maxWidth: constraints.maxWidth);
        final List<LineMetrics> lineMetrics = _painter.computeLineMetrics();
        final bool exceedsBreakpoint = lineMetrics.length > _breakpoint;
        final LineMetrics? lastCollapsedLineMetrics = lineMetrics
            .elementAtOrNull(_maxLinesCollapsed - 1);

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
                style: _style,
                maxLines: switch (exceedsBreakpoint) {
                  false => null,
                  true when _isExpanded => null,
                  true when lastCollapsedLineMetrics!.width <= 0 =>
                    _maxLinesCollapsed - 1,
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
