import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
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

  static const SliverGridDelegateWithMaxCrossAxisExtent gridDelegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
    childAspectRatio: 13 / 9,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    maxCrossAxisExtent: 128 + 64,
  );

  @override
  Widget build(IEpisodesWM wm) {
    return Provider<IEpisodesWM>.value(
      value: wm,
      child: ListenableBuilder(
        listenable:
            Listenable.merge([wm.tabController, wm.tabsTexts, wm.showLoader]),
        builder: (context, __) => wm.showLoader.value
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Scaffold(
                appBar: AppBar(
                  title: const Text('Список эпизодов'),
                  bottom: TabBar(
                    controller: wm.tabController.value,
                    isScrollable: true,
                    tabs: wm.tabsTexts.value
                        .map((text) => Tab(text: text))
                        .toList(growable: false),
                  ),
                ),
                body: ListenableBuilder(
                  listenable: wm.tabEpisodes,
                  builder: (context, __) => TabBarView(
                    controller: wm.tabController.value,
                    children: wm.tabEpisodes.value
                        .map(
                          (episodes) => GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            clipBehavior: Clip.none,
                            gridDelegate: EpisodesWidget.gridDelegate,
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
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Card(
              clipBehavior: Clip.hardEdge,
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
          const SizedBox(height: 4),
          Text(
            context.l10n.movieEpisode(data.type.name, data.number ?? 0),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
