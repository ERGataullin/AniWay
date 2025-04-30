import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/library/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

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
                    floatHeaderSlivers: true,
                    headerSliverBuilder:
                        (context, innerBoxIsScrolled) => [
                          SliverOverlapAbsorber(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context,
                                ),
                            sliver: SliverAppBar(
                              pinned:
                                  MediaQuery.sizeOf(context).height >=
                                  Breakpoints.mediumAndUp.beginHeight!,
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
                        ],
                    body: TabBarView(
                      physics: switch (defaultTargetPlatform) {
                        TargetPlatform.android ||
                        TargetPlatform.fuchsia ||
                        TargetPlatform.iOS => null,
                        TargetPlatform.linux ||
                        TargetPlatform.macOS ||
                        TargetPlatform
                            .windows => const NeverScrollableScrollPhysics(),
                      },
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
    return CustomScrollView(
      key: PageStorageKey(watchStatus),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: EdgeInsets.all(
              Breakpoint.defaultBreakpointOf(context).margin,
            ),
            sliver: SliverPagedGrid(
              gridDelegate: MovieCard.gridDelegate,
              onLoadPage:
                  (page) => context.wm.handleLoadPage(page, watchStatus),
              itemBuilder:
                  (context, movie, animation) =>
                      MovieCard(movie, opacity: animation),
            ),
          ),
        ),
      ],
    );
  }
}
