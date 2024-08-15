import 'package:core/core.dart';
import 'package:flutter/material.dart';
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
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const _AppBar(),
            ListenableBuilder(
              listenable: wm.showLoader,
              builder: (context, __) {
                final TextStyle textStyle =
                    Theme.of(context).textTheme.titleMedium ??
                        DefaultTextStyle.of(context).style;
                return wm.showLoader.value
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    applyTextScaling: true,
                                    size: textStyle.fontSize,
                                    weight:
                                        textStyle.fontWeight?.value.toDouble(),
                                    color: textStyle.color,
                                  ),
                                  const SizedBox(width: 4),
                                  ListenableBuilder(
                                    listenable: wm.score,
                                    builder: (context, __) => Text(
                                      wm.score.value,
                                      style: textStyle,
                                    ),
                                  ),
                                ],
                              ),
                              ListenableBuilder(
                                listenable: wm.title,
                                builder: (context, __) => Text(
                                  wm.title.value,
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _Description(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
        floatingActionButton: _WatchStatusButton(),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.showLoader,
      builder: (context, __) => SliverAppBar(
        expandedHeight: context.wm.showLoader.value ? null : 450,
        leading: IconButton.filledTonal(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.arrow_back),
        ),
        flexibleSpace: context.wm.showLoader.value
            ? null
            : FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.5),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.8),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(1),
                          ],
                          stops: const [
                            0.40,
                            0.70,
                            0.80,
                            1,
                          ],
                        ),
                      ),
                      child: ListenableBuilder(
                        listenable: context.wm.poster,
                        builder: (context, __) => Image(
                          image: context.wm.poster.value!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(64),
                        child: FilledButton.icon(
                          onPressed: context.wm.onPlayPressed,
                          icon: const Icon(Icons.play_arrow_sharp),
                          label: ListenableBuilder(
                            listenable: context.wm.playButtonLabel,
                            builder: (context, __) =>
                                Text(context.wm.playButtonLabel.value),
                          ),
                        ),
                      ),
                    ),
                  ],
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
      builder: (context, __) => Text(context.wm.description.value),
    );
  }
}

class _WatchStatusButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      label: ListenableBuilder(
        listenable: context.wm.watchStatusButtonLabel,
        builder: (context, __) => Text(context.wm.watchStatusButtonLabel.value),
      ),
      icon: const Icon(Icons.add),
    );
  }
}
