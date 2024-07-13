import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_preview.dart';

class MoviePreview extends StatelessWidget {
  const MoviePreview(
    this.data, {
    super.key,
  });

  static const double aspectRatio = 3 / 4;

  final MoviePreviewData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Builder(
          builder: (context) => InkWell(
            onTap: data.onPressed,
            customBorder: Theme.of(context).cardTheme.shape,
            child: Column(
              children: [
                Expanded(
                  child: Ink.image(
                    image: NetworkImage(
                      context
                          .read<Network>()
                          .baseUri
                          .resolveUri(data.posterUri)
                          .toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                _Footer(
                  data,
                  margin: const EdgeInsets.all(8),
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
  const _Footer(
    this.data, {
    this.margin = EdgeInsets.zero,
  });

  static final NumberFormat _scoreFormat = NumberFormat('#0.0');

  final EdgeInsets margin;

  final MoviePreviewData data;

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
              data.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(data.subtitle),
                if (data.score != null) ...[
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
                  Text(_scoreFormat.format(data.score)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
