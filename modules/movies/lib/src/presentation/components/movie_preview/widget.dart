import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/components/movie_preview/widget_model.dart';

extension _MoviePreviewContext on BuildContext {
  IMoviePreviewWM get wm => read<IMoviePreviewWM>();
}

class MoviePreviewWidget extends ElementaryWidget<IMoviePreviewWM> {
  const MoviePreviewWidget({
    super.key,
    required this.movie,
    required this.onPressed,
    WidgetModelFactory wmFactory = moviePreviewWMFactory,
  }) : super(wmFactory);

  static const double aspectRatio = 3 / 4;

  final MoviePreviewData movie;

  final VoidCallback onPressed;

  @override
  Widget build(IMoviePreviewWM wm) {
    return Provider.value(
      value: wm,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Builder(
            builder: (context) => InkWell(
              onTap: onPressed,
              customBorder: Theme.of(context).cardTheme.shape,
              child: const Column(
                children: [
                  _Poster(),
                  _Footer(margin: EdgeInsets.all(8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: context.wm.poster,
        builder: (context, poster, ___) => Ink.image(
          image: poster,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title(),
          const SizedBox(height: 2),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.labelSmall ??
                DefaultTextStyle.of(context).style,
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Type(),
                Expanded(
                  child: SizedBox(width: 16),
                ),
                _Score(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: context.wm.title,
      builder: (context, title, ___) => Text(
        title,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: context.wm.type,
      builder: (context, type, ___) => Text(
        type,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.start,
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score();

  @override
  Widget build(BuildContext context) {
    final TextStyle style = DefaultTextStyle.of(context).style;

    return ListenableBuilder(
      listenable: Listenable.merge([
        context.wm.showScore,
        context.wm.score,
      ]),
      child: Icon(
        Icons.star,
        size: style.fontSize,
        weight: style.fontWeight?.value.toDouble(),
        color: style.color,
      ),
      builder: (context, icon) => Visibility(
        visible: context.wm.showScore.value,
        child: Row(
          children: [
            if (icon != null) icon,
            const SizedBox(width: 4),
            Text(
              context.wm.score.value,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.start,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}
