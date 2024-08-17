import 'package:core/core.dart';
import 'package:flutter/material.dart';
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
    WidgetModelFactory wmFactory = movieWMFactory,
  }) : super(wmFactory);

  final int movieId;

  final void Function(int movieId, int? episodeId) onPlayPressed;

  @override
  Widget build(IMovieWM wm) {
    return Provider<IMovieWM>.value(
      value: wm,
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
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          ListenableBuilder(
                            listenable: wm.score,
                            builder: (context, __) => wm.score.value == null
                                ? const SizedBox.shrink()
                                : MovieScore(
                                    wm.score.value!,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!,
                                  ),
                          ),
                          ListenableBuilder(
                            listenable: wm.title,
                            builder: (context, __) => Text(
                              wm.title.value,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _Description(),
                          // Padding for Extended FAB
                          const SizedBox(height: 16 + 56 + 16),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: wm.showLoader.value ? null : _PlayButton(),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    return ListenableBuilder(
      listenable: context.wm.showLoader,
      builder: (context, __) => SliverAppBar(
        expandedHeight: context.wm.showLoader.value ? null : 400,
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
                        surfaceColor.withOpacity(0),
                        surfaceColor,
                      ],
                    ),
                  ),
                  child: ListenableBuilder(
                    listenable: context.wm.poster,
                    builder: (context, __) => Image(
                      image: context.wm.poster.value!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
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

class _PlayButton extends StatelessWidget {
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
