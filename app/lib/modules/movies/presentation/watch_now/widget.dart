import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/modules/movies/domain/models/movie_preview.dart';
import '/modules/movies/presentation/components/movie_preview/widget.dart';
import '/modules/movies/presentation/components/up_next/widget.dart';
import '/modules/movies/presentation/watch_now/widget_model.dart';

extension _WatchNowContext on BuildContext {
  IWatchNowWidgetModel get wm => read<IWatchNowWidgetModel>();
}

class WatchNowWidget extends ElementaryWidget<IWatchNowWidgetModel> {
  const WatchNowWidget({
    super.key,
    required this.onUpNextPressed,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = watchNowWidgetModelFactory,
  }) : super(wmFactory);

  final void Function(int episodeId, int movieId) onUpNextPressed;

  final void Function(int id) onMoviePressed;

  @override
  Widget build(IWatchNowWidgetModel wm) {
    const EdgeInsets categoriesMargin = EdgeInsets.fromLTRB(16, 4, 16, 16);
    return Provider<IWatchNowWidgetModel>.value(
      value: wm,
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: wm.title,
            builder: (context, title, ___) => Text(title),
          ),
        ),
        body: const Column(
          children: [
            _UpNextCategory(margin: categoriesMargin),
            Divider(
              indent: 16,
              endIndent: 16,
            ),
            _MostPopularCategory(margin: categoriesMargin),
          ],
        ),
      ),
    );
  }
}

class _UpNextCategory extends StatelessWidget {
  const _UpNextCategory({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return _Category(
      margin: margin,
      label: context.wm.upNextLabel,
      child: ValueListenableBuilder(
        valueListenable: context.wm.upNextItems,
        builder: (context, items, ___) => SizedBox(
          height: 256,
          child: ListView.separated(
            itemCount: items.length,
            padding: margin,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => UpNextWidget(
              upNext: items[index],
              onPressed: () => context.wm.onUpNextPressed(
                movieId: items[index].movie.id,
                episodeId: items[index].episode.id,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MostPopularCategory extends StatelessWidget {
  const _MostPopularCategory({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return _Category(
      margin: margin,
      label: context.wm.mostPopularLabel,
      child: _Movies(
        margin: EdgeInsets.only(
          left: margin.left,
          right: margin.right,
        ),
        movies: context.wm.mostPopularItems,
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    this.margin = EdgeInsets.zero,
    required this.label,
    required this.child,
  });

  final EdgeInsets margin;

  final ValueListenable<String> label;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets horizontalMargin = EdgeInsets.only(
      left: margin.left,
      right: margin.right,
    );
    final EdgeInsets verticalMargin = EdgeInsets.only(
      top: margin.top,
      bottom: margin.bottom,
    );

    return Padding(
      padding: verticalMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: horizontalMargin,
            child: ValueListenableBuilder<String>(
              valueListenable: label,
              builder: (context, label, ___) => Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Movies extends StatelessWidget {
  const _Movies({
    this.margin = EdgeInsets.zero,
    required this.movies,
  });

  final EdgeInsets margin;

  final ValueListenable<List<MoviePreviewData>> movies;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: movies,
      builder: (context, movies, ___) => SizedBox(
        height: 256,
        child: ListView.separated(
          itemCount: movies.length,
          padding: margin,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => MoviePreviewWidget(
            movie: movies[index],
            onPressed: () => context.wm.onMoviePressed(movies[index].id),
          ),
        ),
      ),
    );
  }
}
