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
                title: wm.title.value,
                poster: wm.posterUri.value,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    _Description(
                      description: wm.description.value,
                    ),
                  ],
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
    required this.title,
    required this.poster,
  });

  final String title;
  final String poster;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton.filledTonal(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      expandedHeight: 450,
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                height: 350,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(poster),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(64, 16, 64, 16),
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 16),
                    ),
                    icon: const Icon(Icons.play_arrow_sharp),
                    label: const Text('Смотреть'),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                title,
              ),
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FloatingActionButton.extended(
        elevation: 1,
        onPressed: () {},
        label: const Text('Добавить в список'),
        icon: const Icon(Icons.add),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
