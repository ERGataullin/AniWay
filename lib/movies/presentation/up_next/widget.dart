import 'package:app/core/core.dart';
import 'package:app/l10n/context_extension.dart';
import 'package:app/movies/presentation/components/movie_card.dart';
import 'package:app/movies/presentation/up_next/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';

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
          builder:
              (context) => Scaffold(
                appBar: AppBar(
                  clipBehavior: Clip.hardEdge,
                  // TODO(Edgar): Theme it
                  scrolledUnderElevation: 3,
                  shadowColor: ColorScheme.of(context).shadow,
                  title: Text(context.l10n.upNextTitle),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomScrollView(
                    controller: wm.scrollController,
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverSafeArea(
                        sliver: SliverPagedGrid(
                          key: wm.pagedGridKey,
                          controller: wm.scrollController,
                          gridDelegate: MovieCard.gridDelegate,
                          onLoadPage: wm.handleLoadPage,
                          itemBuilder:
                              (context, movie, animation) =>
                                  MovieCard(movie, opacity: animation),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
