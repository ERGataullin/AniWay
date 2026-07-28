import 'dart:ui';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/presentation/components/episode_card.dart';
import 'package:app/movies/presentation/components/movie_score.dart';
import 'package:app/movies/presentation/movie_details/wm.dart';
import 'package:app/movies/presentation/typedefs.dart';
import 'package:app/root_menu/awared_center.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

part 'components/description.dart';
part 'components/episodes.dart';
part 'components/play_button.dart';
part 'components/sliver_app_bar.dart';

extension _MovieDetailsContext on BuildContext {
  IMovieDetailsWM get wm => read<IMovieDetailsWM>();
}

class MovieDetailsWidget extends ElementaryWidget<IMovieDetailsWM> {
  const MovieDetailsWidget({
    super.key,
    required this.movieId,
    required this.onPlayPressed,
    required this.onEpisodePressed,
    required this.episodesUri,
    WidgetModelFactory wmFactory = movieDetailsWMFactory,
  }) : super(wmFactory);

  final int movieId;

  final Uri? episodesUri;

  final OnEpisodePressed onPlayPressed;

  final OnEpisodePressed onEpisodePressed;

  @override
  Widget build(IMovieDetailsWM wm) {
    return Provider<IMovieDetailsWM>.value(
      value: wm,
      child: RootMenuAwaredCenter.builder(
        builder: (context, padding) {
          final bool isMediumAndUp = Breakpoints.mediumAndUp.isActive(context);
          final showFab = isMediumAndUp;
          final double bottomMargin =
              showFab ? context.margin : kFloatingActionButtonMargin * 2 + 56;
          return ShimmerScope(
            child: ValueListenableBuilder(
              valueListenable: wm.loading,
              builder: (context, loading, child) {
                return Scaffold(
                  floatingActionButton: showFab ? null : const _PlayButton(),
                  body: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: padding,
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            const _SliverAppBar(),
                            SliverToBoxAdapter(
                              child: SizedBox(height: context.margin),
                            ),
                            if (loading)
                              const SliverFillRemaining(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              SliverToBoxAdapter(
                                child: Center(
                                  child: _Description(
                                    margin:
                                        context.marginHorizontal +
                                        EdgeInsets.only(
                                          bottom: context.padding,
                                        ),
                                  ),
                                ),
                              ),
                            const SliverToBoxAdapter(child: _Episodes()),
                            SliverToBoxAdapter(
                              child: SizedBox(height: bottomMargin),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
