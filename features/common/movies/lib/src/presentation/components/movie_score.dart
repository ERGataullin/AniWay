import 'package:core/core.dart';
import 'package:flutter/material.dart';

class MovieScore extends StatelessWidget {
  MovieScore(
    this.score, {
    super.key,
    required this.textStyle,
  });

  static final NumberFormat _scoreFormat = NumberFormat('#0.0');

  final double score;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          applyTextScaling: true,
          size: textStyle.fontSize,
          weight: textStyle.fontWeight?.value.toDouble(),
          color: textStyle.color,
        ),
        const SizedBox(width: 4),
        Text(
          _scoreFormat.format(score),
          style: textStyle,
        ),
      ],
    );
  }
}
