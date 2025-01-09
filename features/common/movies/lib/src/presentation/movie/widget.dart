import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/presentation/components/destination_title.dart';
import 'package:movies/src/presentation/components/episode_card.dart';
import 'package:movies/src/presentation/components/movie_score.dart';
import 'package:movies/src/presentation/movie/wm.dart';

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
      child: ShimmerScope(
        child: ListenableBuilder(
          listenable: wm.showLoader,
          builder: (context, __) => Scaffold(
            body: CustomScrollView(
              primary: true,
              slivers: [
                const _AppBar(),
                if (wm.showLoader.value)
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
                      top: false,
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Description(marginTop: 16),
                            _Episodes(marginTop: 16),
                            SizedBox(height: 16 + 56 + 16),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButton: wm.showPlayButton.value
                ? FloatingActionButton.extended(
                    onPressed: context.wm.handlePlayPressed,
                    label: const _PlayLabel(),
                    icon: const Icon(Icons.play_arrow_outlined),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  static List<Shadow> expandedForegroundShadows(BuildContext context) {
    return [
      Shadow(
        blurRadius: 24,
        color: ColorScheme.of(context).shadow,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.posterHeight,
      builder: (context, __) => SliverAppBar(
        pinned: true,
        expandedHeight: context.wm.posterHeight.value,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(
            Icons.adaptive.arrow_back,
            shadows: expandedForegroundShadows(context),
          ),
        ),
        actions: context.wm.showLoader.value
            ? const []
            : const [
                _WatchStatusButton(),
                SizedBox(width: 4),
              ],
        flexibleSpace: context.wm.showLoader.value
            ? null
            : const FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PosterFaded(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Score(),
                          _Title(),
                          SizedBox(height: 8),
                          _Genres(),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _WatchStatusButton extends StatelessWidget {
  const _WatchStatusButton();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        context.wm.watchStatusSelected,
        context.wm.watchStatusButtonTooltip,
      ]),
      builder: (context, __) => IconButton(
        onPressed: () {},
        isSelected: context.wm.watchStatusSelected.value,
        tooltip: context.wm.watchStatusButtonTooltip.value,
        icon: Icon(
          Icons.library_add_outlined,
          shadows: _AppBar.expandedForegroundShadows(context),
        ),
        selectedIcon: Icon(
          Icons.library_add_check_outlined,
          shadows: _AppBar.expandedForegroundShadows(context),
        ),
      ),
    );
  }
}

class _PosterFaded extends StatelessWidget {
  const _PosterFaded();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);
    final Color fadeColor = switch (colorScheme.brightness) {
      Brightness.light => colorScheme.shadow.withValues(alpha: 1),
      Brightness.dark => colorScheme.surface,
    };
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .15, .45, 1],
          colors: [
            fadeColor.withValues(alpha: .4),
            fadeColor.withValues(alpha: 0),
            fadeColor.withValues(alpha: 0),
            fadeColor,
          ],
        ),
      ),
      child: ListenableBuilder(
        listenable: context.wm.poster,
        builder: (context, __) => AdaptiveImageBuilder(
          image: context.wm.poster.value!,
          builder: (context, opacity, image, _) => image == null
              ? const SizedBox.expand()
              : Image(
                  fit: BoxFit.cover,
                  opacity: opacity,
                  image: image,
                ),
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListenableBuilder(
        listenable: context.wm.score,
        builder: (context, __) => switch (context.wm.score.value) {
          null => const SizedBox.shrink(),
          final double score => MovieScore(
              score,
              textStyle: TextTheme.primaryOf(context).titleMedium?.copyWith(
                    shadows: _AppBar.expandedForegroundShadows(context),
                  ),
            )
        },
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListenableBuilder(
        listenable: context.wm.title,
        builder: (context, __) => Text(
          context.wm.title.value,
          style: TextTheme.primaryOf(context).headlineMedium?.copyWith(
                shadows: _AppBar.expandedForegroundShadows(context),
              ),
        ),
      ),
    );
  }
}

class _Genres extends StatelessWidget {
  const _Genres();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Драма · Фэнтези · Триллер · Исекай · '
        'Психологическое · Путешествие во времени',
        style: TextTheme.primaryOf(context).labelLarge?.copyWith(
              shadows: _AppBar.expandedForegroundShadows(context),
            ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({this.marginTop = 0});

  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.description,
      builder: (context, __) => switch (context.wm.description.value) {
        final String description when description.isNotEmpty => Padding(
            padding: EdgeInsets.only(top: marginTop) +
                const EdgeInsets.symmetric(horizontal: 16),
            child: ExpandableText(description),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes({this.marginTop = 0});

  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.showEpisodes,
      builder: (context, __) => !context.wm.showEpisodes.value
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(top: marginTop),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: context.wm.episodesUri,
                    builder: (context, __) => DestinationTitle(
                      context.wm.episodesLabel,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      uri: context.wm.episodesUri.value,
                      trailing: ListenableBuilder(
                        listenable: context.wm.episodesCount,
                        builder: (context, __) =>
                            Text(context.wm.episodesCount.value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 128,
                    child: ListenableBuilder(
                      listenable: context.wm.episodes,
                      builder: (context, __) => ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        itemCount: context.wm.episodes.value.length,
                        separatorBuilder: (context, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) => _Episode(
                          context.wm.episodes.value[index],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PlayLabel extends StatelessWidget {
  const _PlayLabel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.playButtonLabel,
      builder: (context, __) => Text(context.wm.playButtonLabel.value),
    );
  }
}

class _Episode extends StatelessWidget {
  const _Episode(this.data);

  final EpisodeData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: EpisodeCard(
        data,
        onPressed: context.wm.handleEpisodePressed,
      ),
    );
  }
}
