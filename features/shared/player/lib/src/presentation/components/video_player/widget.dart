import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:player/src/domain/models/seek_type.dart';
import 'package:player/src/presentation/components/fullscreen/fullscreen_button.dart';
import 'package:player/src/presentation/components/long_seek_button.dart';
import 'package:player/src/presentation/components/scalable.dart';
import 'package:player/src/presentation/components/seek_area/widget.dart';
import 'package:player/src/presentation/components/show_on_mouse_hover.dart';
import 'package:player/src/presentation/components/video_play_pause_loader.dart';
import 'package:player/src/presentation/components/video_player/typedefs.dart';
import 'package:player/src/presentation/components/video_player/wm.dart';
import 'package:player/src/presentation/components/video_seek_bar.dart';
import 'package:player/src/presentation/components/video_timer.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:theme/theme.dart';
import 'package:video_player/video_player.dart' as video_player;

extension _VideoPlayerContext on BuildContext {
  IVideoPlayerWM get wm => read<IVideoPlayerWM>();
}

class VideoPlayerWidget extends ElementaryWidget<IVideoPlayerWM> {
  const VideoPlayerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.translations,
    required this.videoResolver,
    this.onPreviousPressed,
    this.onNextPressed,
    required this.onWatched,
    required this.onFinished,
    WidgetModelFactory wmFactory = videoPlayerWMFactory,
  }) : super(wmFactory);

  final String title;

  final String subtitle;

  final List<VideoTranslationData> translations;

  final VideoResolver videoResolver;

  final VoidCallback? onPreviousPressed;

  final VoidCallback? onNextPressed;

  final TranslationWatchedCallback onWatched;

  final VoidCallback onFinished;

  @override
  Widget build(IVideoPlayerWM wm) {
    return Provider<IVideoPlayerWM>.value(
      value: wm,
      child: Theme(
        data: Themes.videoPlayer,
        child: PopScope(
          onPopInvoked: wm.onPopInvoked,
          child: const Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                _Gestures(child: _Player()),
                _Controls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Gestures extends StatelessWidget {
  const _Gestures({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([
            context.wm.maxScale,
            context.wm.scaleAnchors,
          ]),
          builder: (context, __) => Scalable(
            maxScale: context.wm.maxScale.value,
            anchors: context.wm.scaleAnchors.value,
            child: child,
          ),
        ),
        GestureDetector(onTapUp: context.wm.onTapUp),
        Row(
          children: [
            _buildSeekArea(context, type: SeekType.rewind),
            _buildSeekArea(context, type: SeekType.fastForward),
          ],
        ),
      ],
    );
  }

  Widget _buildSeekArea(
    BuildContext context, {
    required SeekType type,
  }) {
    return Expanded(
      child: SeekAreaWidget(
        videoController: context.wm.videoController,
        type: type,
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Center(
            child: ListenableBuilder(
              listenable: context.wm.videoController.aspectRatio,
              builder: (context, __) => AspectRatio(
                aspectRatio: context.wm.videoController.aspectRatio.value,
                child: switch (context.wm.videoController) {
                  final VideoPlayerController videoPlayerController =>
                    ListenableBuilder(
                      listenable: videoPlayerController.inner,
                      builder: (context, __) =>
                          videoPlayerController.inner.value == null
                              ? const SizedBox.shrink()
                              : video_player.VideoPlayer(
                                  videoPlayerController.inner.value!,
                                ),
                    ),
                },
              ),
            ),
          ),
          ListenableBuilder(
            listenable: context.wm.controlsVisibilityController,
            builder: (context, __) => AnimatedVisibility.emphasized(
              visible: context.wm.controlsVisibilityController.visible,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return ShowOnMouseHover(
      controller: context.wm.controlsVisibilityController,
      child: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AppBar(
                forceMaterialTransparency: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(context.wm.title),
                    _Title(
                      context.wm.subtitle,
                      style: Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                  ],
                ),
                actions: const [_MenuButton()],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkipButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: context.wm.previousCallback,
                ),
                const SizedBox(width: 48),
                VideoPlayPauseLoader(
                  videoController: context.wm.videoController,
                ),
                const SizedBox(width: 48),
                _SkipButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: context.wm.nextCallback,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        VideoTimer(videoController: context.wm.videoController),
                        const SizedBox(width: 16),
                        LongSeekButton(
                          videoController: context.wm.videoController,
                          type: SeekType.rewind,
                        ),
                        LongSeekButton(
                          videoController: context.wm.videoController,
                          type: SeekType.fastForward,
                        ),
                        const Spacer(),
                        FullscreenButton(
                          controller: context.wm.fullscreenController,
                        ),
                      ],
                    ),
                    VideoSeekBar(
                      videoController: context.wm.videoController,
                      onPositionChangeStart: context.wm.onPositionChangeStart,
                      onPositionChangeEnd: context.wm.onPositionChangeEnd,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(
    this.data, {
    this.style,
  });

  final ValueListenable<String> data;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: data,
      builder: (context, data, ___) => AnimatedSwitcher(
        switchInCurve: Easing.standard,
        switchOutCurve: Easing.standard.flipped,
        duration: Durations.medium2,
        child: Text(
          data,
          key: Key(data),
          style: style,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.menuCallback,
      builder: (context, __) => IconButton(
        icon: const Icon(Icons.settings_outlined),
        onPressed: context.wm.menuCallback.value,
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.onPressed,
    required this.icon,
  });

  final ValueListenable<VoidCallback?> onPressed;

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: onPressed,
      builder: (context, __) => IconButton.filledTonal(
        iconSize: 36,
        onPressed: onPressed.value,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        icon: icon,
      ),
    );
  }
}
