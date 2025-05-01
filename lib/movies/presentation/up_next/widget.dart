import 'package:app/core/core.dart';
import 'package:app/l10n/context_extension.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/up_next/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class UpNextWidget extends ElementaryWidget<IUpNextWM> {
  const UpNextWidget({
    super.key,
    required this.onItemPressed,
    required this.onItemLongPressed,
    WidgetModelFactory wmFactory = upNextWMFactory,
  }) : super(wmFactory);

  final void Function(int movieId, int episodeId) onItemPressed;

  final void Function(int movieId, int episodeId) onItemLongPressed;

  @override
  Widget build(IUpNextWM wm) {
    return RootMenuAwaredCenter(
      child: ShimmerScope(
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: NestedScrollView(
                headerSliverBuilder:
                    (context, innerBoxIsScrolled) => [
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                        sliver: SliverAppBar(
                          pinned: true,
                          forceElevated: innerBoxIsScrolled,
                          title: Text(context.l10n.upNextTitle),
                        ),
                      ),
                    ],
                body: CustomScrollView(
                  slivers: [
                    Builder(
                      builder: (context) {
                        return SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                context,
                              ),
                        );
                      },
                    ),
                    SliverSafeArea(
                      sliver: SliverPadding(
                        padding: EdgeInsets.all(
                          Breakpoint.activeBreakpointOf(context).margin,
                        ),
                        sliver: SliverPagedGrid(
                          key: wm.pagedGridKey,
                          gridDelegate: MovieCard.gridDelegate(context),
                          onLoadPage: wm.handleLoadPage,
                          itemBuilder:
                              (context, movie, animation) =>
                                  MovieCard(movie, opacity: animation),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
