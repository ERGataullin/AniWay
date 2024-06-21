import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/components/movie_preview.dart';
import 'package:movies/src/presentation/home/wm.dart';

extension _HomeContext on BuildContext {
  IHomeWM get wm => read<IHomeWM>();
}

class HomeWidget extends ElementaryWidget<IHomeWM> {
  const HomeWidget({
    super.key,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = homeWMFactory,
  }) : super(wmFactory);

  final void Function(Object id) onMoviePressed;

  @override
  Widget build(IHomeWM wm) {
    const EdgeInsets categoriesMargin = EdgeInsets.symmetric(horizontal: 16);
    return Provider<IHomeWM>.value(
      value: wm,
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: wm.title,
            builder: (context, title, ___) => Text(title),
          ),
        ),
        body: ListenableBuilder(
          listenable: wm.showLoader,
          builder: (context, __) => AnimatedSwitcher(
            switchInCurve: Curves.easeInOutCubicEmphasized,
            switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
            duration: Durations.long2,
            child: wm.showLoader.value
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Builder(
                    builder: (context) {
                      final EdgeInsets safeAreaPadding =
                          MediaQuery.paddingOf(context);
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 16 + safeAreaPadding.top,
                          bottom: 16 + safeAreaPadding.bottom,
                        ),
                        child: const Column(
                          children: [
                            _UpNextCategory(margin: categoriesMargin),
                            SafeArea(
                              child: Divider(
                                indent: 16,
                                endIndent: 16,
                                height: 32,
                              ),
                            ),
                            _PopularCategory(margin: categoriesMargin),
                          ],
                        ),
                      );
                    },
                  ),
          ),
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
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return _Category(
      margin: margin,
      label: context.wm.upNextLabel,
      child: ValueListenableBuilder(
        valueListenable: context.wm.upNextItems,
        builder: (context, items, ___) => SizedBox(
          height: 256,
          child: ListView.separated(
            itemCount: items.length,
            padding: margin.add(
              EdgeInsets.only(
                left: safeAreaPadding.left,
                right: safeAreaPadding.right,
              ),
            ),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final UpNextData upNext = items[index];
              return MoviePreview(
                posterUri: upNext.movie.posterUri,
                title: upNext.movie.title,
                subtitle: context.l10n.movieEpisode(
                  upNext.episode.type.name,
                  upNext.episode.number ?? 0,
                ),
                onPressed: () => context.wm.onUpNextPressed(
                  movieId: upNext.movie.id,
                  episodeId: upNext.episode.id,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PopularCategory extends StatelessWidget {
  const _PopularCategory({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return _Category(
      margin: margin,
      label: context.wm.popularLabel,
      child: _Movies(
        margin: EdgeInsets.only(
          left: margin.left,
          right: margin.right,
        ),
        movies: context.wm.popularItems,
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
          SafeArea(
            child: Padding(
              padding: horizontalMargin,
              child: ValueListenableBuilder<String>(
                valueListenable: label,
                builder: (context, label, ___) => Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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

  final ValueListenable<List<MovieBaseData>> movies;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return ValueListenableBuilder(
      valueListenable: movies,
      builder: (context, movies, ___) => SizedBox(
        height: 256,
        child: ListView.separated(
          itemCount: movies.length,
          padding: margin.add(
            EdgeInsets.only(
              left: safeAreaPadding.left,
              right: safeAreaPadding.right,
            ),
          ),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final MovieBaseData movie = movies[index];
            return MoviePreview(
              posterUri: movie.posterUri,
              title: movie.title,
              subtitle: context.l10n.movieType(movie.type.name),
              score: movie.score,
              onPressed: () => context.wm.onMoviePressed(movie.id),
            );
          },
        ),
      ),
    );
  }
}
