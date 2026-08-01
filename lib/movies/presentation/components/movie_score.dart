import 'package:app/core/core.dart';
import 'package:flutter/material.dart';

class MovieScore extends StatelessWidget {
  const MovieScore(this.score, {super.key, this.textStyle});

  static final _scoreFormat = NumberFormat('#0.0');

  final double? score;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveTextStyle =
        textStyle ?? DefaultTextStyle.of(context).style;
    if (score == null) {
      effectiveTextStyle = effectiveTextStyle.copyWith(
        color: Colors.transparent,
      );
    }

    return Shimmer(
      enabled: score == null,
      delegate: const DecoratedBoxShimmerDelegate(
        decoration: BoxDecoration(borderRadius: .all(.circular(4))),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            applyTextScaling: true,
            size: effectiveTextStyle.fontSize,
            weight: effectiveTextStyle.fontWeight?.value.toDouble(),
            color: effectiveTextStyle.color,
            shadows: effectiveTextStyle.shadows,
          ),
          const SizedBox(width: 4),
          Text(_scoreFormat.format(score ?? 0), style: effectiveTextStyle),
        ],
      ),
    );
  }
}
