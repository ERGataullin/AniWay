import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/presentation/components/movie_score.dart';

class MovieCard extends StatelessWidget {
  const MovieCard(
    this.data, {
    super.key,
  });

  static const SliverGridDelegateWithMaxCrossAxisExtent gridDelegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 3 / 4,
    maxCrossAxisExtent: 128 + 64,
  );

  final MovieCardData data;

  @override
  Widget build(BuildContext context) {
    final CardTheme cardTheme = CardTheme.of(context);
    return AspectRatio(
      aspectRatio: gridDelegate.childAspectRatio,
      child: Card(
        child: InkWell(
          onTap: data.onPressed,
          customBorder: cardTheme.shape,
          child: Column(
            children: [
              Expanded(
                child: Ink(
                  decoration: ShapeDecoration(
                    shape: cardTheme.shape!,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        context
                            .read<Network>()
                            .baseUri
                            .resolveUri(data.posterUri)
                            .toString(),
                      ),
                    ),
                  ),
                ),
              ),
              _Footer(
                data,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
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

  final EdgeInsets margin;

  final MovieCardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: DefaultTextStyle(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.labelSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(data.subtitle),
                ),
                if (data.score != null) ...[
                  const SizedBox(width: 16),
                  MovieScore(
                    data.score!,
                    textStyle: Theme.of(context).textTheme.labelSmall!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
