import 'package:app/core/core.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/movies.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/components/search_bar.dart';
import 'package:app/movies/presentation/search/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';

class MoviesSearchWidget extends ElementaryWidget<IMoviesSearchWM> {
  const MoviesSearchWidget({
    super.key,
    this.isOngoing,
    this.query,
    this.order = MoviesOrder.byPopularity,
    required this.onSearch,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = moviesSearchWMFactory,
  }) : super(wmFactory);

  final bool? isOngoing;

  final String? query;

  final MoviesOrder order;

  final OnMoviesSearch onSearch;

  final void Function(int id) onMoviePressed;

  @override
  Widget build(IMoviesSearchWM wm) {
    return Provider<IMoviesSearchWM>.value(
      value: wm,
      child: ShimmerScope(
        child: ListenableBuilder(
          listenable: wm.query,
          builder: (context, body) => Scaffold(
            extendBodyBehindAppBar: true,
            appBar: RootMenu.hasTopNavigation(context)
                ? null
                : MoviesSearchBar(
                    query: wm.query.value,
                    onSearch: onSearch,
                  ),
            body: body,
          ),
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              controller: wm.scrollController,
              slivers: [
                Builder(
                  builder: (context) => SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.paddingOf(context).top + 16,
                      16,
                      16,
                    ),
                    sliver: SliverPagedGrid(
                      key: wm.pagedGridKey,
                      controller: wm.scrollController,
                      gridDelegate: MovieCard.gridDelegate,
                      onLoadPage: wm.handleLoadPage,
                      itemBuilder: (context, movie, animation) => MovieCard(
                        movie,
                        opacity: animation,
                      ),
                    ),
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
