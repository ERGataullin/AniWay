import 'package:app/core/core.dart';
import 'package:app/movies/domain/models/movie_card.dart';
import 'package:app/movies/presentation/components/movie_score.dart';
import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  const MovieCard(
    this.data, {
    super.key,
    this.opacity,
  });

  static const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 3 / 4,
    maxCrossAxisExtent: 128 + 64,
  );

  final Animation<double>? opacity;

  final MovieCardData? data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CardThemeData cardTheme = CardTheme.of(context);

    return AspectRatio(
      aspectRatio: gridDelegate.childAspectRatio,
      child: ConditionalWrapper(
        condition: opacity != null,
        wrapper: (context, child) {
          final themeTween = ThemeDataTween(
            begin: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                surfaceContainerLow:
                    theme.colorScheme.surfaceContainerLow.withValues(alpha: 0),
                surfaceContainerHighest: theme
                    .colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0),
              ),
              textTheme: theme.textTheme.copyWith(
                titleSmall: theme.textTheme.titleSmall?.copyWith(
                  color:
                      theme.textTheme.titleSmall?.color?.withValues(alpha: 0),
                ),
                labelSmall: theme.textTheme.labelSmall?.copyWith(
                  color:
                      theme.textTheme.labelSmall?.color?.withValues(alpha: 0),
                ),
              ),
              cardColor: theme.cardColor.withValues(alpha: 0),
              cardTheme: theme.cardTheme.copyWith(
                color: cardTheme.color?.withValues(alpha: 0),
                shadowColor: cardTheme.shadowColor?.withValues(alpha: 0),
                surfaceTintColor:
                    cardTheme.surfaceTintColor?.withValues(alpha: 0),
                elevation: 0,
              ),
            ),
            end: theme,
          );

          return AnimatedBuilder(
            animation: opacity!,
            builder: (context, __) => Theme(
              data: themeTween.evaluate(opacity!),
              child: child,
            ),
          );
        },
        child: Card(
          child: InkWell(
            onTap: data?.onPressed,
            onLongPress: data?.onLongPressed,
            customBorder: cardTheme.shape,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Poster(
                    opacity: opacity,
                    image: data?.poster,
                  ),
                ),
                _Footer(
                  data,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({
    this.opacity,
    this.image,
  });

  final Animation<double>? opacity;

  final ImageData? image;

  @override
  Widget build(BuildContext context) {
    return AdaptiveImageBuilder(
      image: image,
      builder: (context, fadeInOpacity, image, ____) => ListenableBuilder(
        listenable: Listenable.merge([opacity, fadeInOpacity]),
        builder: (context, _) => Shimmer(
          enabled: fadeInOpacity.value != 1,
          delegate: CustomShimmerDelegate(
            (context, color, gradient, ___) => Ink(
              decoration: ShapeDecoration(
                shape: CardTheme.of(context).shape!,
                color: color,
                gradient: gradient,
                image: image == null
                    ? null
                    : DecorationImage(
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        opacity: fadeInOpacity.value * (opacity?.value ?? 1),
                        image: image,
                      ),
              ),
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

  final EdgeInsets margin;

  final MovieCardData? data;

  @override
  Widget build(BuildContext context) {
    const ShimmerDelegate shimmerDelegate = DecoratedBoxShimmerDelegate(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
    final TextTheme textTheme = TextTheme.of(context);
    return Padding(
      padding: margin,
      child: DefaultTextStyle(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: textTheme.labelSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer(
              enabled: data?.title == null,
              constraints: const BoxConstraints(minWidth: 128),
              delegate: shimmerDelegate,
              child: Text(
                data?.title ?? '',
                style: textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Shimmer(
                    enabled: data?.subtitle == null,
                    delegate: shimmerDelegate,
                    child: Text(data?.subtitle ?? ''),
                  ),
                ),
                if (data == null || data?.score != null) ...[
                  const SizedBox(width: 16),
                  MovieScore(data?.score),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
