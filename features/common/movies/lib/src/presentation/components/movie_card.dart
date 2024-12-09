import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/presentation/components/movie_score.dart';

class MovieCard extends StatelessWidget {
  const MovieCard(
    this.data, {
    super.key,
    this.opacity,
  });

  static const SliverGridDelegateWithMaxCrossAxisExtent gridDelegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
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
    final CardTheme cardTheme = CardTheme.of(context);

    return AspectRatio(
      aspectRatio: gridDelegate.childAspectRatio,
      child: ConditionalWrapper(
        condition: opacity != null,
        wrapper: (context, child) {
          final ThemeDataTween themeTween = ThemeDataTween(
            begin: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                surfaceContainerLow:
                    theme.colorScheme.surfaceContainerLow.withOpacity(0),
                surfaceContainerHighest:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0),
              ),
              textTheme: theme.textTheme.copyWith(
                titleSmall: theme.textTheme.titleSmall?.copyWith(
                  color: theme.textTheme.titleSmall?.color?.withOpacity(0),
                ),
                labelSmall: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.labelSmall?.color?.withOpacity(0),
                ),
              ),
              cardColor: theme.cardColor.withOpacity(0),
              cardTheme: theme.cardTheme.copyWith(
                color: cardTheme.color?.withOpacity(0),
                shadowColor: cardTheme.shadowColor?.withOpacity(0),
                surfaceTintColor: cardTheme.surfaceTintColor?.withOpacity(0),
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
            customBorder: cardTheme.shape,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Poster(
                    opacity: opacity,
                    uri: data?.posterUri,
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

class _Poster extends StatefulWidget {
  const _Poster({
    this.opacity,
    this.uri,
  });

  final Animation<double>? opacity;

  final Uri? uri;

  @override
  State<_Poster> createState() => _PosterState();
}

class _PosterState extends State<_Poster> {
  @override
  Widget build(BuildContext context) {
    final NetworkImage? image = widget.uri == null
        ? null
        : NetworkImage(
            context.read<Network>().baseUri.resolveUri(widget.uri!).toString(),
          );
          
    return ListenableBuilder(
      listenable: Listenable.merge([widget.opacity]),
      builder: (context, __) => FadeInImageBuilder(
        image: image,
        builder: (context, fadeInOpacity, image, ____) => Shimmer(
          enabled: fadeInOpacity != 1,
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
                        opacity: fadeInOpacity * (widget.opacity?.value ?? 1),
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
    final TextTheme textTheme = Theme.of(context).textTheme;
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
                  Shimmer(
                    enabled: data == null,
                    delegate: shimmerDelegate,
                    child: MovieScore(data?.score ?? 0),
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
