import 'package:core/core.dart';
import 'package:flutter/material.dart';

class MovieScore extends StatelessWidget {
  const MovieScore(
    this.score, {
    super.key,
    this.textStyle,
  });

  static final NumberFormat _scoreFormat = NumberFormat('#0.0');

  final double score;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveTextStyle =
        textStyle ?? DefaultTextStyle.of(context).style;
    return Row(
      children: [
        Icon(
          Icons.star,
          applyTextScaling: true,
          size: effectiveTextStyle.fontSize,
          weight: effectiveTextStyle.fontWeight?.value.toDouble(),
          color: effectiveTextStyle.color,
        ),
        const SizedBox(width: 4),
        Text(
          _scoreFormat.format(score),
          style: effectiveTextStyle,
        ),
      ],
    );
  }
}
