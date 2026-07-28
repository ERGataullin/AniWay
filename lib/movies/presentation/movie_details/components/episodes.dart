part of '../widget.dart';

class _Episodes extends StatelessWidget {
  const _Episodes();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: context.wm.episodesUri,
          builder: (context, episodesUri, child) {
            return DestinationTitle(
              context.l10n.episodesLabel,
              margin: context.marginHorizontal,
              uri: episodesUri,
              trailing: Text(context.l10n.xOfY(64, 64)),
            );
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 128,
          child: ValueListenableBuilder(
            valueListenable: context.wm.episodes,
            builder: (context, episodes, child) {
              return ListView.separated(
                clipBehavior: Clip.hardEdge,
                scrollDirection: Axis.horizontal,
                padding: context.marginHorizontal,
                itemCount: episodes.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 16 / 10,
                    child: EpisodeCard(
                      episodes[index],
                      onPressed: context.wm.handleEpisodePressed,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
