import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/watch_status.dart';
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
            child: ShimmerScope(
              child: DefaultTabController(
                length: wm.watchStatuses.length,
                child: Scaffold(
                  body: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                context,
                              ),
                          sliver: SliverAppBar(
                            pinned: true,
                            forceElevated: innerBoxIsScrolled,
                            title: Text(context.l10n.libraryTitle),
                            bottom: TabBar(
                              isScrollable: true,
                              tabs: wm.tabsTexts.value
                                  .map((text) => Tab(text: text))
                                  .toList(growable: false),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: wm.watchStatuses
                          .map(
                            (watchStatus) => _Movies(watchStatus: watchStatus),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class _Movies extends StatelessWidget {
  const _Movies({this.watchStatus});

  final WatchStatus? watchStatus;
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final ScrollController scrollController = PrimaryScrollController.of(
          context,
        );
        return CustomScrollView(
          key: PageStorageKey(watchStatus),
          // controller: scrollController,
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
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
