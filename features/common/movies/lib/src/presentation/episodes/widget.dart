import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/components/episode_card.dart';
import 'package:movies/src/presentation/episodes/wm.dart';

extension _EpisodesContext on BuildContext {
  IEpisodesWM get wm => read<IEpisodesWM>();
}

class EpisodesWidget extends ElementaryWidget<IEpisodesWM> {
  const EpisodesWidget({
    super.key,
    required this.movieId,
    required this.onEpisodePressed,
    WidgetModelFactory wmFactory = episodesWMFactory,
  }) : super(wmFactory);

  final int movieId;

  final void Function(int? episodeId) onEpisodePressed;

  @override
  Widget build(IEpisodesWM wm) {
    return Provider<IEpisodesWM>.value(
      value: wm,
      child: ShimmerScope(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            wm.tabController,
            wm.tabsTexts,
            wm.episodesLabel,
          ]),
          builder: (context, __) => Scaffold(
            appBar: AppBar(
              title: Text(wm.episodesLabel.value),
              bottom: wm.tabController.value == null
                  ? null
                  : TabBar(
                      controller: wm.tabController.value,
                      isScrollable: true,
                      tabs: wm.tabsTexts.value
                          .map((text) => Tab(text: text))
                          .toList(growable: false),
                    ),
            ),
            body: wm.tabController.value == null
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : const _Episodes(),
          ),
        ),
      ),
    );
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.tabsEpisodes,
      builder: (context, __) => TabBarView(
        controller: context.wm.tabController.value,
        children: context.wm.tabsEpisodes.value
            .map(
              (episodes) => GridView.builder(
                clipBehavior: Clip.none,
                padding: const EdgeInsets.all(16),
                itemCount: episodes.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 16 / 10,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  maxCrossAxisExtent: 128 + 64,
                ),
                itemBuilder: (context, index) => EpisodeCard(
                  episodes[index],
                  onPressed: context.wm.handleEpisodePressed,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
