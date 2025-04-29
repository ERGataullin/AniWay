import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/movie_card.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/home/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      builder:
          (context, _) => ShimmerScope(
            child: Scaffold(
              appBar:
                  RootMenuScope.of(context).hasTopNavigation(context)
                      ? null
                      : AppBar(
                        centerTitle: true,
                        title: const FittedBox(child: Logo(primary: false)),
                      ),
              body: const _Body(),
            ),
          ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return RootMenuAwaredCenter(
      child: ConstrainedContent(
        child: ListenableBuilder(
          listenable: context.wm.loading,
          builder:
              (context, _) => AnimatedSwitcher(
                switchInCurve: Easing.emphasizedDecelerate,
                switchOutCurve: Easing.emphasizedAccelerate.flipped,
                duration: Durations.medium4,
                reverseDuration: Durations.short4,
                layoutBuilder:
                    (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                child:
                    context.wm.loading.value
                        ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                        : const _Content(),
              ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return RefreshIndicator.adaptive(
      onRefresh: context.wm.handleRefresh,
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                primary: true,
                padding: EdgeInsets.only(
                  top: 16 + safeAreaPadding.top,
                  bottom: 16 + safeAreaPadding.bottom,
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    _Category(
                      title: context.l10n.upNextTitle,
                      uri: context.wm.upNextUri,
                      movies: context.wm.upNextItems,
                    ),
                    _Category(
                      title: context.l10n.ongoingsTitle,
                      uri: context.wm.ongoingsUri,
                      movies: context.wm.ongoingItems,
                    ),
                    _Category(
                      title: context.l10n.popularsTitle,
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

  final String title;

  final Uri uri;

  final ValueListenable<List<MovieCardData>> movies;

  @override
  Widget build(BuildContext context) {
    const marginHorizontal = EdgeInsets.symmetric(horizontal: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DestinationTitle(title, uri: uri, margin: marginHorizontal),
        const SizedBox(height: 8),
        _Movies(margin: marginHorizontal, movies: movies),
      ],
    );
  }
}

class _Movies extends StatelessWidget {
  const _Movies({this.margin = EdgeInsets.zero, required this.movies});

  final EdgeInsets margin;

  final ValueListenable<List<MovieCardData>> movies;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return SizedBox(
      height: 128 + 64 + 32,
      child: ValueListenableBuilder(
        valueListenable: movies,
        builder:
            (context, movies, _) => ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              padding: margin.add(
                EdgeInsets.only(
                  left: safeAreaPadding.left,
                  right: safeAreaPadding.right,
                ),
              ),
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => MovieCard(movies[index]),
            ),
      ),
    );
  }
}
