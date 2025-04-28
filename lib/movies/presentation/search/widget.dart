import 'package:app/core/core.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/movies.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/components/search_bar.dart';
import 'package:app/movies/presentation/search/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class MoviesSearchWidget extends ElementaryWidget<IMoviesSearchWM> {
  const MoviesSearchWidget({
    super.key,
    this.isOngoing,
    this.query,
    this.order = MoviesOrder.byPopularity,
    this.typesExcluded = const [],
    required this.onSearch,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = moviesSearchWMFactory,
  }) : super(wmFactory);

  final bool? isOngoing;

  final String? query;

  final MoviesOrder order;

  final List<MovieType> typesExcluded;

  final OnMoviesSearch onSearch;

  final void Function(int id) onMoviePressed;

  @override
  Widget build(IMoviesSearchWM wm) {
    return RootMenuAwaredCenter(
      child: ShimmerScope(
        child: ListenableBuilder(
          listenable: wm.query,
          builder:
              (context, body) => Scaffold(
                extendBodyBehindAppBar: true,
                appBar:
                    RootMenuScope.of(context).hasTopNavigation(context)
                        ? null
                        : MoviesSearchBar(
                          query: wm.query.value,
                          onSearch: onSearch,
                        ),
                body: body,
              ),
          child: CustomScrollView(
            slivers: [
              SliverSafeArea(
                sliver: Builder(
                  builder: (context) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        Breakpoint.defaultBreakpointOf(context).margin,
                        0,
                        Breakpoint.defaultBreakpointOf(context).margin,
                        Breakpoint.defaultBreakpointOf(context).margin,
                      ),
                      sliver: SliverPagedGrid(
                        key: wm.pagedGridKey,
                        gridDelegate: MovieCard.gridDelegate,
                        onLoadPage: wm.handleLoadPage,
                        itemBuilder:
                            (context, movie, animation) =>
                                MovieCard(movie, opacity: animation),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
