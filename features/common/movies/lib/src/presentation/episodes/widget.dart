import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/episode.dart';
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
              : ListenableBuilder(
                  listenable: wm.tabsEpisodes,
                  builder: (context, __) => TabBarView(
                    controller: wm.tabController.value,
                    children: wm.tabsEpisodes.value
                        .map(
                          (episodes) => GridView.builder(
                            padding: const EdgeInsets.all(16),
                            clipBehavior: Clip.none,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 13 / 9,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              maxCrossAxisExtent: 128 + 64,
                            ),
                            itemCount: episodes.length,
                            itemBuilder: (context, index) => _Episode(
                              episodes[index],
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Episode extends StatelessWidget {
  const _Episode(this.data);

  final EpisodeData data;

  @override
  Widget build(BuildContext context) {
    final CardTheme cardTheme = CardTheme.of(context);
    return InkWell(
      onTap: () => context.wm.handleEpisodePressed(data.id),
      customBorder: cardTheme.shape!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: data.previewUri == null
                  ? null
                  : SizedBox(
                      width: double.infinity,
                      child: Image(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              context.wm.getEpisodeTitle(data),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
