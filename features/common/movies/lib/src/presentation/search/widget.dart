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
    this.isOngoing,
    this.order = MoviesOrder.byPopularity,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = moviesSearchWMFactory,
  }) : super(wmFactory);

  final bool? isOngoing;

  final MoviesOrder order;

  final void Function(int id) onMoviePressed;

  @override
  Widget build(IMoviesSearchWM wm) {
    return Provider<IMoviesSearchWM>.value(
      value: wm,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const _SearchBar(),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            controller: wm.scrollController,
            slivers: [
              Builder(
                builder: (context) => SliverPagedGrid(
                  key: wm.pagedGridKey,
                  scrollController: wm.scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.paddingOf(context).top,
                    16,
                    16,
                  ),
                  gridDelegate: MovieCard.gridDelegate,
                  loader: wm.handleLoadPage,
                  itemBuilder: (context, movie, animation) =>
                      MovieCard.animated(
                    movie,
                    opacity: animation,
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

class _SearchBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchBar();

  static const double _margin = 16;

  @override
  Size get preferredSize => const Size.fromHeight(_margin + 56 + _margin);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_margin),
      child: ListenableBuilder(
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
                switchOutCurve: Easing.standardAccelerate.flipped,
                child: context.wm.showClearButton.value
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: context.wm.handleClearPressed,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
