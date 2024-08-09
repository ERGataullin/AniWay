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

  final void Function(int movieId) onPlayPressed;

  @override
  Widget build(IMovieWM wm) {
    return Provider<IMovieWM>.value(
      value: wm,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const _AppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListenableBuilder(
                  listenable: wm.showLoader,
                  builder: (context, __) {
                    return wm.showLoader.value
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    applyTextScaling: true,
                                    size: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize,
                                    weight: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontWeight
                                        ?.value
                                        .toDouble(),
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.color,
                                  ),
                                  const SizedBox(width: 4),
                                  ListenableBuilder(
                                    listenable: wm.score,
                                    builder: (context, __) => Text(
                                      wm.score.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
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
                          );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _FAB(),
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
        expandedHeight: 450,
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
                    ListenableBuilder(
                      listenable: context.wm.poster,
                      builder: (context, __) => Image(
                        image: context.wm.poster.value!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
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

class _FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      label: ListenableBuilder(
        listenable: context.wm.detailsFABLabel,
        builder: (context, __) => Text(context.wm.detailsFABLabel.value),
      ),
      icon: const Icon(Icons.add),
    );
  }
}
