import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_card.dart';
import 'package:movies/src/presentation/components/movie_card.dart';
import 'package:movies/src/presentation/home/wm.dart';

extension _HomeContext on BuildContext {
  IHomeWM get wm => read<IHomeWM>();
}

class HomeWidget extends ElementaryWidget<IHomeWM> {
  const HomeWidget({
    super.key,
    required this.upNextUri,
    required this.onUpNextPressed,
    required this.ongoingsUri,
    required this.popularsUri,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = homeWMFactory,
  }) : super(wmFactory);

  final Uri upNextUri;

  final void Function(int movieId, int episodeId) onUpNextPressed;

  final Uri ongoingsUri;

  final Uri popularsUri;

  final void Function(int id) onMoviePressed;

  @override
  Widget build(IHomeWM wm) {
    return Provider<IHomeWM>.value(
      value: wm,
      child: ShimmerScope(
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
              switchInCurve: Easing.emphasizedDecelerate,
              switchOutCurve: Easing.emphasizedAccelerate.flipped,
              duration: Durations.medium4,
              reverseDuration: Durations.short4,
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: wm.showLoader.value
                  ? const Center(
                      key: ValueKey('Loader'),
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : const _Content(key: ValueKey('Content')),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return RefreshIndicator(
      onRefresh: context.wm.handleRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          primary: true,
          padding: EdgeInsets.only(
            top: 16 + safeAreaPadding.top,
            bottom: 16 + safeAreaPadding.bottom,
          ),
          child: MediaQuery.removePadding(
            removeTop: true,
            removeBottom: true,
            context: context,
            child: Column(
              spacing: 16,
              children: [
                _Category(
                  title: context.wm.upNextTitle,
                  uri: context.wm.upNextUri,
                  movies: context.wm.upNextItems,
                ),
                _Category(
                  title: context.wm.ongoingsTitle,
                  uri: context.wm.ongoingsUri,
                  movies: context.wm.ongoingItems,
                ),
                _Category(
                  title: context.wm.popularsTitle,
                  uri: context.wm.popularsUri,
                  movies: context.wm.popularItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    required this.title,
    required this.uri,
    required this.movies,
  });

  final ValueListenable<String> title;

  final Uri uri;

  final ValueListenable<List<MovieCardData>> movies;

  @override
  Widget build(BuildContext context) {
    const marginHorizontal = EdgeInsets.symmetric(horizontal: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DestinationTitle(
          title,
          uri: uri,
          margin: marginHorizontal,
        ),
        const SizedBox(height: 8),
        _Movies(
          margin: marginHorizontal,
          movies: movies,
        ),
      ],
    );
  }
}

class _Movies extends StatelessWidget {
  const _Movies({
    this.margin = EdgeInsets.zero,
    required this.movies,
  });

  final EdgeInsets margin;

  final ValueListenable<List<MovieCardData>> movies;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return SizedBox(
      height: 128 + 64 + 32,
      child: ValueListenableBuilder(
        valueListenable: movies,
        builder: (context, movies, ___) => ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          padding: margin.add(
            EdgeInsets.only(
              left: safeAreaPadding.left,
              right: safeAreaPadding.right,
            ),
          ),
          separatorBuilder: (context, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => MovieCard(movies[index]),
        ),
      ),
    );
  }
}
