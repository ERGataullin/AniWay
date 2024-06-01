import 'package:core/core.dart';
import 'package:flutter/material.dart';

class MoviePreview extends StatelessWidget {
  const MoviePreview({
    super.key,
    required this.posterUri,
    required this.title,
    required this.subtitle,
    this.score,
    required this.onPressed,
  });

  static const double aspectRatio = 3 / 4;

  final Uri posterUri;

  final String title;

  final String subtitle;

  final double? score;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Builder(
          builder: (context) => InkWell(
            onTap: onPressed,
            customBorder: Theme.of(context).cardTheme.shape,
            child: Column(
              children: [
                Expanded(
                  child: Ink.image(
                    image: NetworkImage(
                      context
                          .read<Network>()
                          .baseUri
                          .resolveUri(posterUri)
                          .toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                _Footer(
                  margin: const EdgeInsets.all(8),
                  title: title,
                  subtitle: subtitle,
                  score: score,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    this.margin = EdgeInsets.zero,
    required this.title,
    required this.subtitle,
    this.score,
  });

  static final NumberFormat _scoreFormat = NumberFormat('#0.0');

  final EdgeInsets margin;

  final String title;

  final String subtitle;

  final double? score;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.labelSmall ??
        DefaultTextStyle.of(context).style;
    return Padding(
      padding: margin,
      child: DefaultTextStyle(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.start,
        style: textStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                ),
                if (score != null) ...[
                  const Expanded(
                    child: SizedBox(width: 16),
                  ),
                  Icon(
                    Icons.star,
                    applyTextScaling: true,
                    size: textStyle.fontSize,
                    weight: textStyle.fontWeight?.value.toDouble(),
                    color: textStyle.color,
                  ),
                  const SizedBox(width: 4),
                  Text(_scoreFormat.format(score)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
