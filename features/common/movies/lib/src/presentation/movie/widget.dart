import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/presentation/components/destination_title.dart';
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
                  const SliverSafeArea(
                    top: false,
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          _Score(),
                          _Title(),
                          _Description(marginTop: 16),
                          _Episodes(marginTop: 16),
                          SizedBox(height: 16 + 56 + 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButton:
                wm.showPlayButton.value ? const _PlayButton() : null,
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = ColorScheme.of(context).surface;
    return ListenableBuilder(
      listenable: context.wm.posterHeight,
      builder: (context, __) => SliverAppBar(
        pinned: true,
        expandedHeight: context.wm.posterHeight.value,
        leading: IconButton.filledTonal(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        actions: context.wm.showLoader.value
            ? const []
            : [
                ListenableBuilder(
                  listenable: Listenable.merge([
                    context.wm.watchStatusSelected,
                    context.wm.watchStatusButtonTooltip,
                  ]),
                  builder: (context, __) => IconButton.filledTonal(
                    onPressed: () {},
                    isSelected: context.wm.watchStatusSelected.value,
                    tooltip: context.wm.watchStatusButtonTooltip.value,
                    icon: const Icon(Icons.library_add_outlined),
                    selectedIcon: const Icon(Icons.library_add_check_outlined),
                  ),
                ),
                const SizedBox(width: 4),
              ],
        flexibleSpace: context.wm.showLoader.value
            ? null
            : FlexibleSpaceBar(
                background: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(0, .8),
                      end: Alignment.bottomCenter,
                      colors: [
                        surfaceColor.withValues(alpha: 0),
                        surfaceColor,
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
              textStyle: TextTheme.of(context).titleMedium,
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
          style: TextTheme.of(context).headlineLarge,
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

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: context.wm.handlePlayPressed,
      label: ListenableBuilder(
        listenable: context.wm.playButtonLabel,
        builder: (context, __) => Text(context.wm.playButtonLabel.value),
      ),
      icon: const Icon(Icons.play_arrow_outlined),
    );
  }
}

class _Episode extends StatelessWidget {
  const _Episode(this.data);

  final EpisodeData data;

  @override
  Widget build(BuildContext context) {
    final CardThemeData cardTheme = CardTheme.of(context);
    return GestureDetector(
      onTap: () => context.wm.handleEpisodePressed(data.id),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () => context.wm.handleEpisodePressed(data.id),
                    customBorder: cardTheme.shape!,
                    child: data.previewUri == null
                        ? null
                        : Image(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              context
                                  .read<Network>()
                                  .baseUri
                                  .resolveUri(data.previewUri!)
                                  .toString(),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.wm.getEpisodeTitle(data),
              style: TextTheme.of(context).labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
