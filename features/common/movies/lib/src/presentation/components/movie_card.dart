import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/presentation/components/movie_score.dart';

class MovieCard extends StatelessWidget {
  const MovieCard(
    this.data, {
    super.key,
  }) : opacity = null;

  const MovieCard.animated(
    this.data, {
    super.key,
    required Animation<double> this.opacity,
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
    final ThemeDataTween themeTween = ThemeDataTween(
      begin: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          surfaceContainerLow:
              theme.colorScheme.surfaceContainerLow.withOpacity(0),
        ),
        textTheme: theme.textTheme.copyWith(
          titleSmall: theme.textTheme.titleSmall?.copyWith(
            color: theme.textTheme.titleSmall?.color?.withOpacity(0),
          ),
          labelSmall: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.labelSmall?.color?.withOpacity(0),
          ),
        ),
        cardTheme: theme.cardTheme.copyWith(
          color: cardTheme.color?.withOpacity(0),
          shadowColor: cardTheme.shadowColor?.withOpacity(0),
          surfaceTintColor: cardTheme.surfaceTintColor?.withOpacity(0),
          elevation: 0,
        ),
      ),
      end: theme,
    );

    return AspectRatio(
      aspectRatio: gridDelegate.childAspectRatio,
      child: ConditionalWrapper(
        condition: opacity != null,
        wrapper: (context, child) => AnimatedBuilder(
          animation: opacity!,
          builder: (context, __) => Theme(
            data: themeTween.evaluate(opacity!),
            child: child,
          ),
        ),
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
  late ShapeBorder _shape;
  ImageProvider<Object>? _imageProvider;
  String? _url;

  @override
  void didChangeDependencies() {
    _shape = CardTheme.of(context).shape!;

    if (widget.uri != null) {
      final String url = context
          .read<Network>()
          .baseUri
          .resolveUri(widget.uri ?? Uri())
          .toString();
      if (url != _url) {
        _imageProvider = NetworkImage(url);
        _url = url;
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageProvider == null) return const SizedBox.shrink();
    return widget.opacity == null
        ? _buildFadeInImage(context)
        : AnimatedBuilder(
            animation: widget.opacity!,
            builder: (context, __) => _buildFadeInImage(context),
          );
  }

  Widget _buildFadeInImage(BuildContext context) {
    return FadeInImageBuilder(
      duration: Durations.medium1,
      curve: Easing.standardDecelerate,
      image: _imageProvider!,
      builder: (context, fadeInOpacity, ___) => Ink(
        decoration: ShapeDecoration(
          shape: _shape,
          image: DecorationImage(
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            opacity: fadeInOpacity * (widget.opacity?.value ?? 1),
            image: _imageProvider!,
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
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: margin,
      child: DefaultTextStyle(
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.start,
        style: textTheme.labelSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data?.title ?? '',
              style: textTheme.titleSmall,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(data?.subtitle ?? ''),
                ),
                if (data?.score != null) ...[
                  const SizedBox(width: 16),
                  MovieScore(data?.score ?? 0),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
