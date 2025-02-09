import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/movies.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/search/wm.dart';
import 'package:flutter/material.dart';

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
      child: ShimmerScope(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const _SearchBar(),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              controller: wm.scrollController,
              slivers: [
                Builder(
                  builder: (context) => SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.paddingOf(context).top,
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

class _SearchBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchBar();

  static const double _margin = 16;

  @override
  Size get preferredSize => const Size.fromHeight(_margin + 56 + _margin);

  @override
  Widget build(BuildContext context) {
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    return SafeArea(
      child: ConditionalWrapper(
        condition: appBarTheme.systemOverlayStyle != null,
        wrapper: (context, child) => AnnotatedRegion(
          value: appBarTheme.systemOverlayStyle!,
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.all(_margin),
          child: ListenableBuilder(
            listenable: context.wm.queryController,
            builder: (context, __) => SearchBar(
              controller: context.wm.queryController,
              leading: Navigator.canPop(context)
                  ? const BackButton()
                  : IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search_outlined),
                    ),
              hintText: context.l10n.searchPageTitle,
              trailing: context.wm.queryController.text.isEmpty
                  ? null
                  : [
                      IconButton(
                        onPressed: context.wm.handleClearPressed,
                        icon: const Icon(Icons.clear_outlined),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
