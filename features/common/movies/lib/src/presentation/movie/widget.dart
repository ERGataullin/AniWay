import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/movie/wm.dart';

class MovieWidget extends ElementaryWidget<IMovieWM> {
  const MovieWidget({
    super.key,
    required this.movieId,
    WidgetModelFactory wmFactory = movieWMFactory,
  }) : super(wmFactory);

  final int movieId;

  @override
  Widget build(IMovieWM wm) {
    return Provider<IMovieWM>.value(
      value: wm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          wm.title,
          wm.posterUri,
        ]),
        builder: (context, __) => Scaffold(
          body: CustomScrollView(
            slivers: [
              _AppBar(
                poster: wm.posterUri.value,
              ),
            ],
          ),
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
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: BackButton(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            elevation: 1,
          ),
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.height / 5 * 2,
      flexibleSpace: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(poster),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 64, 16),
            child: FilledButton.icon(
              onPressed: () {},
              style: IconButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.play_arrow_sharp),
              label: const Text('Смотреть'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FloatingActionButton.extended(
        elevation: 1,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        onPressed: () {},
        label: const Text('Добавить в список'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
