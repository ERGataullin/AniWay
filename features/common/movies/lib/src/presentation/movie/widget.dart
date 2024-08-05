import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/movie/wm.dart';

class MovieWidget extends ElementaryWidget<IMovieWM> {
  const MovieWidget({
    super.key,
    required this.movieId,
    WidgetModelFactory wmFactory = movieWMFactory,
  }) : super(wmFactory);

  static final NumberFormat _scoreFormat = NumberFormat('#0.0');

  final int movieId;

  @override
  Widget build(IMovieWM wm) {
    return Provider<IMovieWM>.value(
      value: wm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          wm.title,
          wm.posterUri,
          wm.showLoader,
          wm.score,
        ]),
        builder: (context, __) => wm.showLoader.value
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Scaffold(
                body: CustomScrollView(
                  slivers: [
                    _AppBar(
                      poster: wm.posterUri.value,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            if (wm.score.value != null)
                              Text(
                                _scoreFormat.format(wm.score.value),
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            Text(
                              wm.title.value,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 16),
                            _Description(
                              description: wm.description.value,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: _FAB(),
              ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.poster,
  });

  final String poster;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 450,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton.filledTonal(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              poster,
              fit: BoxFit.cover,
            ),
            Center(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_sharp),
                label: const Text('Смотреть'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Text(description);
  }
}

class _FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      label: const Text('В список'),
      icon: const Icon(Icons.add),
    );
  }
}
