import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:flutter/material.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard(this.data, {super.key, this.onPressed});

  final EpisodeData data;

  final void Function(int id)? onPressed;

  @override
  Widget build(BuildContext context) {
    final CardThemeData cardTheme = CardTheme.of(context);
    return InkWell(
      onTap: onPressed == null ? null : () => onPressed!(data.id),
      customBorder: cardTheme.shape!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child:
                  data.preview == null
                      ? Center(
                        child: Text(
                          data.number?.toString() ?? '1',
                          style: TextTheme.of(
                            context,
                          ).displayLarge?.copyWith(fontFamily: 'Alvida'),
                        ),
                      )
                      : AdaptiveImageBuilder(
                        image: data.preview,
                        builder:
                            (context, opacity, image, ____) =>
                                ListenableBuilder(
                                  listenable: opacity,
                                  builder:
                                      (context, __) => Shimmer(
                                        enabled: opacity.value < 1,
                                        delegate: DecoratedBoxShimmerDelegate(
                                          decoration: ShapeDecoration(
                                            shape: CardTheme.of(context).shape!,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.low,
                                              opacity: opacity.value,
                                              image: image!,
                                            ),
                                          ),
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              context.l10n.movieEpisode(data.type.name, data.number ?? 0),
              style: TextTheme.of(context).titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
