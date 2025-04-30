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
              appBar: AppBar(
                clipBehavior: Clip.hardEdge,
                title: Text(context.l10n.upNextTitle),
              ),
              body: CustomScrollView(
                slivers: [
                  SliverSafeArea(
                    sliver: SliverPadding(
                      padding: EdgeInsets.all(
                        Breakpoint.activeBreakpointOf(context).margin,
                      ),
                      sliver: SliverPagedGrid(
                        key: wm.pagedGridKey,
                        gridDelegate: MovieCard.gridDelegate,
                        onLoadPage: wm.handleLoadPage,
                        itemBuilder:
                            (context, movie, animation) =>
                                MovieCard(movie, opacity: animation),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
