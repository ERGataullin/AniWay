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
    const padding = EdgeInsets.symmetric(horizontal: 16);
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
                  SliverSafeArea(
                    top: false,
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: padding,
                            child: ListenableBuilder(
                              listenable: wm.score,
                              builder: (context, __) => wm.score.value == null
                                  ? const SizedBox.shrink()
                                  : MovieScore(
                                      wm.score.value!,
                                      textStyle:
                                          TextTheme.of(context).titleMedium!,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: padding,
                            child: ListenableBuilder(
                              listenable: wm.title,
                              builder: (context, __) => Text(
                                wm.title.value,
                                style: TextTheme.of(context).headlineLarge,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: padding,
                            child: _Description(),
                          ),
                          const SizedBox(height: 16),
                          ListenableBuilder(
                            listenable: context.wm.showEpisodes,
                            builder: (context, __) =>
                                context.wm.showEpisodes.value
                                    ? const _Episodes()
                                    : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16 + 56 + 16),
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
        expandedHeight: context.wm.posterHeight.value,
        leading: IconButton.filledTonal(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.arrow_back),
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
                    icon: const Icon(Icons.library_add),
                    selectedIcon: const Icon(Icons.library_add_check),
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

class _Description extends StatelessWidget {
  const _Description();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.description,
      builder: (context, __) => ExpandableText(context.wm.description.value),
    );
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes();

  @override
  Widget build(BuildContext context) {
    return Column(
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
              builder: (context, __) => Text(
                context.wm.episodesCount.value,
                style: TextTheme.of(context).titleMedium?.copyWith(
                      color: TextTheme.of(context)
                          .titleMedium
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 128,
          child: ListenableBuilder(
            listenable: context.wm.episodes,
            builder: (context, __) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: context.wm.episodes.value.length,
              separatorBuilder: (context, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _Episode(
                context.wm.episodes.value[index],
              ),
            ),
          ),
        ),
      ],
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
      icon: const Icon(Icons.play_arrow),
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
