import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/presentation/components/episode_card.dart';
import 'package:app/movies/presentation/components/movie_score.dart';
import 'package:app/movies/presentation/movie/wm.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

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
            listenable: Listenable.merge([wm.loading, wm.episodes]),
            builder: (context, _) {
              return Scaffold(
                floatingActionButton:
                    wm.episodes.value.isEmpty
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

class _AppBar extends StatelessWidget {
  const _AppBar();

  static bool isScrolledUnder(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!
        .isScrolledUnder!;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.loading,
      builder: (context, loading, _) {
        return SliverAppBar.large(
          pinned: true,
          expandedHeight:
              loading ? null : MediaQuery.sizeOf(context).width * 1.25,
          title: const _Title(),
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: Builder(
              builder: (context) {
                return ConditionalWrapper(
                  condition: !isScrolledUnder(context),
                  child: Icon(Icons.adaptive.arrow_back),
                  wrapper: (context, child) {
                    return IconTheme(
                      data: Theme.of(context).primaryIconTheme,
                      child: child,
                    );
                  },
                );
              },
            ),
          ),
          actions: loading ? null : const [_WatchStatusButton()],
          flexibleSpace: const _AppBarFlexibleSpace(),
        );
      },
    );
  }
}

class _AppBarFlexibleSpace extends StatelessWidget {
  const _AppBarFlexibleSpace();

  @override
  Widget build(BuildContext context) {
    final Color scrimColor = ColorScheme.of(context).scrim;
    return ValueListenableBuilder(
      valueListenable: context.wm.loading,
      builder: (context, loading, _) {
        return loading
            ? const SizedBox.shrink()
            : FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const _Poster(),
                  Align(
                    alignment: Alignment.topCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scrimColor.withValues(alpha: .5),
                            scrimColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: AppBarTheme.of(context).toolbarHeight!,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, .25, .75, 1],
                          colors: [
                            scrimColor.withValues(alpha: 0),
                            scrimColor.withValues(alpha: .5),
                            scrimColor.withValues(alpha: .9),
                            scrimColor,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          Breakpoint.activeBreakpointOf(context).margin,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Отступ для более плавного градиента.
                            SizedBox(height: 32),
                            _Score(),
                            _Title(),
                            SizedBox(height: 8),
                            _Genres(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
      },
    );
  }
}

class _WatchStatusButton extends StatelessWidget {
  const _WatchStatusButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.watchStatus,
      builder: (context, watchStatus, _) {
        return ConditionalWrapper(
          condition: !_AppBar.isScrolledUnder(context),
          wrapper: (context, child) {
            return IconTheme(
              data: Theme.of(context).primaryIconTheme,
              child: child,
            );
          },
          child: IconButton(
            onPressed: () => context.wm.handleWatchStatusPressed(context),
            isSelected: watchStatus != null,
            tooltip: switch (watchStatus) {
              null => context.l10n.watchStatusTitle,
              final WatchStatus other => context.l10n.watchStatus(other.name),
            },
            icon: const Icon(Icons.library_add_outlined),
            selectedIcon: const Icon(Icons.library_add_check_outlined),
          ),
        );
      },
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
                  ValueListenableBuilder(
                    valueListenable: context.wm.episodesUri,
                    builder: (context, episodesUri, _) {
                      return DestinationTitle(
                        context.l10n.episodesLabel,
                        margin: EdgeInsets.symmetric(
                          horizontal:
                              Breakpoint.activeBreakpointOf(context).margin,
                        ),
                        uri: episodesUri,
                        trailing: const _EpisodesCount(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 128,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            Breakpoint.activeBreakpointOf(context).margin,
                      ),
                      clipBehavior: Clip.none,
                      scrollDirection: Axis.horizontal,
                      itemCount: episodes.length,
                      separatorBuilder:
                          (context, _) => const SizedBox(width: 8),
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

class _EpisodesCount extends StatelessWidget {
  const _EpisodesCount();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.episodesCount,
      builder: (context, episodesCount, _) {
        return Text(switch (context.wm.episodesCount.value) {
          final int episodesCount => context.l10n.xOfY(
            min(context.wm.episodes.value.length, episodesCount),
            episodesCount,
          ),
          _ => context.l10n.releasedCount(context.wm.episodes.value.length),
        });
      },
    );
  }
}
