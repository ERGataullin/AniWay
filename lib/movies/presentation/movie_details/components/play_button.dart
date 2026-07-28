part of '../widget.dart';

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: context.wm.handlePlayPressed,
      label: Text(context.l10n.playLabel),
      icon: const Icon(Icons.play_arrow_outlined),
    );
  }
}
