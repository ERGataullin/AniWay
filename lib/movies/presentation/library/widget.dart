import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/library/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';

extension _LibraryContext on BuildContext {
  ILibraryWM get wm => read<ILibraryWM>();
}

class LibraryWidget extends ElementaryWidget<ILibraryWM> {
  const LibraryWidget({
    super.key,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = libraryWMFactory,
  }) : super(wmFactory);

  final void Function(int) onMoviePressed;

  @override
  Widget build(ILibraryWM wm) {
    return Provider<ILibraryWM>.value(
      value: wm,
      builder:
          (context, _) => RootMenuAwaredCenter(
            child: ConstrainedContent(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(context.l10n.libraryTitle),
                  // bottom: TabBar(
                  //   controller: wm.tabController.value,
                  //   isScrollable: true,
                  //   tabs: wm.tabsTexts.value
                  //       .map((text) => Tab(text: text))
                  //       .toList(growable: false),
                  // ),
                ),
                body: const _Movies(),
              ),
            ),
          ),
    );
  }
}

class _Movies extends StatelessWidget {
  const _Movies();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final ScrollController scrollController = PrimaryScrollController.of(
          context,
        );
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            Builder(
              builder:
                  (context) => SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16 + MediaQuery.paddingOf(context).top,
                      16,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverPagedGrid(
                      controller: scrollController,
                      gridDelegate: MovieCard.gridDelegate,
                      onLoadPage:
                          (page) => context.wm.handleLoadPage(page, null),
                      itemBuilder:
                          (context, movie, animation) =>
                              MovieCard(movie, opacity: animation),
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }
}
