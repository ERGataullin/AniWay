import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/components/movie_card.dart';
import 'package:movies/src/presentation/search/wm.dart';

extension _SearchContext on BuildContext {
  IMoviesSearchWM get wm => read<IMoviesSearchWM>();
}

class MoviesSearchWidget extends ElementaryWidget<IMoviesSearchWM> {
  const MoviesSearchWidget({
    super.key,
    this.order = MoviesOrder.byPopularity,
    this.isOngoing,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = moviesSearchWMFactory,
  }) : super(wmFactory);

  final MoviesOrder order;

  final bool? isOngoing;

  final void Function(int id) onMoviePressed;

  @override
  Widget build(IMoviesSearchWM wm) {
    return Provider<IMoviesSearchWM>.value(
      value: wm,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            clipBehavior: Clip.none,
            controller: wm.scrollController,
            slivers: [
              const SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverPagedGrid.maxCrossAxisExtent(
                  key: wm.pagedGridKey,
                  scrollController: wm.scrollController,
                  gridDelegate: MovieCard.gridDelegate,
                  loader: wm.handleLoadPage,
                  itemBuilder: (context, movie, ___) => MovieCard(movie),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  const _SearchBarDelegate({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => 56 + margin.vertical;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: margin,
      child: SearchAnchor(
        suggestionsBuilder: (context, controller) => [
          const SizedBox.shrink(),
        ],
        builder: (context, controller) => ListenableBuilder(
          listenable: context.wm.queryHint,
          builder: (context, __) => SearchBar(
            controller: context.wm.queryController,
            leading: context.wm.showBackButton
                ? const BackButton()
                : IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
            hintText: context.wm.queryHint.value,
            trailing: [
              ListenableBuilder(
                listenable: context.wm.showClearButton,
                builder: (context, __) => AnimatedSwitcher(
                  duration: Durations.medium1,
                  reverseDuration: Durations.short4,
                  switchInCurve: Easing.standardDecelerate,
                  switchOutCurve: Easing.standardAccelerate,
                  child: context.wm.showClearButton.value
                      ? SizedBox.shrink()
                      : IconButton(
                          onPressed: context.wm.handleClearPress,
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
