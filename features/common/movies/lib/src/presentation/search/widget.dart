import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/presentation/components/movie_preview.dart';
import 'package:movies/src/presentation/search/wm.dart';

extension _SearchContext on BuildContext {
  ISearchWM get wm => read<ISearchWM>();
}

class SearchWidget extends ElementaryWidget<ISearchWM> {
  const SearchWidget({
    super.key,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = searchWMFactory,
  }) : super(wmFactory);

  final void Function(Object id) onMoviePressed;

  @override
  Widget build(ISearchWM wm) {
    return Provider<ISearchWM>.value(
      value: wm,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            controller: wm.scrollController,
            slivers: const [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(margin: EdgeInsets.all(16)),
              ),
              _Result(margin: EdgeInsets.symmetric(horizontal: 16)),
              SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              _Loader(margin: EdgeInsets.fromLTRB(16, 8, 16, 8)),
              SliverToBoxAdapter(
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
        builder: (context, controller) => ValueListenableBuilder(
          valueListenable: context.wm.queryHint,
          builder: (context, hintText, ___) => SearchBar(
            controller: context.wm.queryController,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            leading: const Icon(Icons.search),
            hintText: hintText,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _Result extends StatelessWidget {
  const _Result({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: margin,
      sliver: ValueListenableBuilder(
        valueListenable: context.wm.movies,
        builder: (context, items, ___) => SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: MoviePreview.aspectRatio,
            maxCrossAxisExtent: 200,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final MovieBaseData movie = items[index];
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

class _Loader extends StatelessWidget {
  const _Loader({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: context.wm.showLoader,
          builder: (context, showLoader, ___) => Visibility(
            visible: showLoader,
            child: Padding(
              padding: margin,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
