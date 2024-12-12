import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/components/movie_card.dart';
import 'package:movies/src/presentation/up_next/wm.dart';

class UpNextWidget extends ElementaryWidget<IUpNextWM> {
  const UpNextWidget({
    super.key,
    required this.onItemPressed,
    WidgetModelFactory wmFactory = upNextWMFactory,
  }) : super(wmFactory);

  final void Function(int movieId, int episodeId) onItemPressed;

  @override
  Widget build(IUpNextWM wm) {
    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: wm.title,
          builder: (context, __) => Text(wm.title.value),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            controller: wm.scrollController,
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverPagedGrid(
                key: wm.pagedGridKey,
                controller: wm.scrollController,
                gridDelegate: MovieCard.gridDelegate,
                onLoadPage: wm.handleLoadPage,
                itemBuilder: (context, movie, animation) => MovieCard(
                  movie,
                  opacity: animation,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
