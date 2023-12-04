import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/components/video_player/widget_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

extension _VideoPlayerContext on BuildContext {
  IVideoPlayerWidgetModel get wm => read<IVideoPlayerWidgetModel>();
}

class VideoPlayerWidget extends ElementaryWidget<IVideoPlayerWidgetModel> {
  const VideoPlayerWidget.fromTranslations({
    super.key,
    required this.title,
    required this.translations,
    this.onFinished,
    WidgetModelFactory wmFactory = videoPlayerWidgetModelFactory,
  }) : super(wmFactory);

  final String title;
  final Map<VideoTranslationTypeData, List<VideoTranslationData>> translations;
  final void Function(Object translationId)? onFinished;

  @override
  Widget build(IVideoPlayerWidgetModel wm) {
    return Provider<IVideoPlayerWidgetModel>.value(
      value: wm,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            _Player(),
            _Controls(),
          ],
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: context.wm.showPlayer,
        builder: (context, showPlayer, ___) => Visibility(
          child: ValueListenableBuilder<double>(
            valueListenable: context.wm.aspectRatio,
            builder: (context, aspectRation, ___) => AspectRatio(
              aspectRatio: aspectRation,
              child: ValueListenableBuilder<VideoPlayerController>(
                valueListenable: context.wm.controller,
                builder: (context, controller, ___) => VideoPlayer(controller),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    const Color background = Colors.black45;
    final ThemeData theme = Theme.of(context);

    return ValueListenableBuilder<MouseCursor>(
      valueListenable: context.wm.mouseCursor,
      builder: (context, mouseCursor, child) => MouseRegion(
        opaque: false,
        cursor: mouseCursor,
        onHover: context.wm.onPointerHover,
        child: child,
      ),
      child: Theme(
        data: theme.copyWith(
          scaffoldBackgroundColor: background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          colorScheme: theme.colorScheme.copyWith(
            background: background,
            onBackground: Colors.white,
          ),
        ),
        child: ValueListenableBuilder<Duration>(
          valueListenable: context.wm.controlsAnimationDuration,
          child: const Scaffold(
            body: Stack(
              children: [
                _Top(),
                _PlayPauseButton(),
                _Bottom(),
              ],
            ),
          ),
          builder: (context, duration, child) => ValueListenableBuilder<bool>(
            valueListenable: context.wm.showControls,
            builder: (context, showControls, ___) => AnimatedSwitcher(
              switchInCurve: Easing.emphasizedDecelerate,
              // TODO(ERGataullin): replace with Easing.emphasized
              switchOutCurve: Easing.emphasizedAccelerate,
              duration: duration,
              child: showControls ? child : const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AppBar(
        title: const _Title(),
        actions: const [
          _PreferencesButton(),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: context.wm.title,
      builder: (context, title, ___) => Text(title),
    );
  }
}

class _PreferencesButton extends StatelessWidget {
  const _PreferencesButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      onPressed: context.wm.onPreferencesPressed,
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: IconButton(
        onPressed: context.wm.onPlayPausePressed,
        icon: AnimatedIcon(
          size: 48,
          icon: AnimatedIcons.play_pause,
          progress: context.wm.playPauseAnimation,
        ),
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Timer(),
            _SeekBar(),
          ],
        ),
      ),
    );
  }
}

class _Timer extends StatelessWidget {
  const _Timer();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: context.wm.duration,
      builder: (context, duration, ___) => ValueListenableBuilder<String>(
        valueListenable: context.wm.position,
        builder: (context, position, ___) => RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.87),
                ),
            children: [
              TextSpan(
                text: position,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(1),
                ),
              ),
              const TextSpan(text: ' / '),
              TextSpan(text: duration),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ValueListenableBuilder<VideoPlayerController>(
        valueListenable: context.wm.controller,
        builder: (context, controller, ___) => VideoProgressIndicator(
          controller,
          key: ValueKey(controller),
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
