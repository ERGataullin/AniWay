import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/presentation/components/episode_card.dart';
import 'package:app/movies/presentation/components/movie_score.dart';
import 'package:app/movies/presentation/movie/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'components/app_bar.dart';

extension _MovieContext on BuildContext {
  IMovieWM get wm => read<IMovieWM>();
}

class MovieWidget extends ElementaryWidget<IMovieWM> {
  const MovieWidget({
    super.key,
    required this.movieId,
    required this.onPlayPressed,
    required this.onEpisodePressed,
    required this.episodesUri,
    WidgetModelFactory wmFactory = movieWMFactory,
  }) : super(wmFactory);

  final int movieId;

  final Uri? episodesUri;

  final void Function(int? episodeId) onPlayPressed;

  final void Function(int? episodeId) onEpisodePressed;

  @override
  Widget build(IMovieWM wm) {
    return Provider<IMovieWM>.value(
      value: wm,
      child: RootMenuAwaredCenter(
        child: ShimmerScope(
          child: ListenableBuilder(
            listenable: .merge([wm.loading, wm.episodes]),
            builder: (context, _) {
              return Scaffold(
                floatingActionButton: wm.episodes.value.isEmpty
                    ? null
                    : FloatingActionButton.extended(
                        onPressed: context.wm.handlePlayPressed,
                        label: Text(context.l10n.playLabel),
                        icon: const Icon(Icons.play_arrow_outlined),
                      ),
                body: CustomScrollView(
                  slivers: [
                    const _AppBar(),
                    if (wm.loading.value)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else
                      MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: const SliverSafeArea(
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Description(marginTop: 16),
                                _Episodes(marginTop: 16),
                                SizedBox(
                                  height: kFloatingActionButtonMargin * 2 + 56,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: ValueListenableBuilder(
        valueListenable: context.wm.poster,
        builder: (context, poster, _) {
          return AdaptiveImageBuilder(
            image: poster,
            builder: (context, opacity, image, _) {
              return image == null
                  ? const SizedBox.expand()
                  : Image(fit: BoxFit.cover, opacity: opacity, image: image);
            },
          );
        },
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.score,
      builder: (context, score, _) {
        return switch (score) {
          null => const SizedBox.shrink(),
          final double score => MovieScore(
            score,
            textStyle: TextTheme.primaryOf(context).titleMedium,
          ),
        };
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.title,
      builder: (context, title, _) {
        return Text(title, style: TextTheme.primaryOf(context).headlineMedium);
      },
    );
  }
}

class _Genres extends StatelessWidget {
  const _Genres();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.genres,
      builder: (context, genres, _) {
        return Text(
          genres.join('\u{00A0}· '),
          style: TextTheme.primaryOf(context).labelLarge,
        );
      },
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({this.marginTop = 0});

  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.description,
      builder: (context, description, _) {
        return switch (description) {
          final String description when description.isNotEmpty => Padding(
            padding:
                EdgeInsets.only(top: marginTop) +
                EdgeInsets.symmetric(
                  horizontal: Breakpoint.activeBreakpointOf(context).margin,
                ),
            child: ExpandableText(description),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes({this.marginTop = 0});

  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.episodes,
      builder: (context, episodes, _) {
        return episodes.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.only(top: marginTop),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _EpisodesTitle(),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 128,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: Breakpoint.activeBreakpointOf(
                            context,
                          ).margin,
                        ),
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        itemCount: episodes.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return AspectRatio(
                            aspectRatio: 16 / 10,
                            child: EpisodeCard(
                              episodes[index],
                              onPressed: context.wm.handleEpisodePressed,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

class _EpisodesTitle extends StatelessWidget {
  const _EpisodesTitle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.episodesUri,
      builder: (context, episodesUri, _) {
        return DestinationTitle(
          context.l10n.episodesLabel,
          margin: EdgeInsets.symmetric(
            horizontal: Breakpoint.activeBreakpointOf(context).margin,
          ),
          uri: episodesUri,
          trailing: ValueListenableBuilder(
            valueListenable: context.wm.episodesCount,
            builder: (context, episodesCount, _) {
              return Text(switch (context.wm.episodesCount.value) {
                final int episodesCount => context.l10n.xOfY(
                  min(context.wm.episodes.value.length, episodesCount),
                  episodesCount,
                ),
                _ => context.l10n.releasedCount(
                  context.wm.episodes.value.length,
                ),
              });
            },
          ),
        );
      },
    );
  }
}
