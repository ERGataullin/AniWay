import 'package:app/core/core.dart';
import 'package:app/player/domain/models/seek_type.dart';
import 'package:app/player/player.dart';
import 'package:app/player/presentation/video_player/components/fullscreen/fullscreen_button.dart';
import 'package:app/player/presentation/video_player/components/long_seek_button.dart';
import 'package:app/player/presentation/video_player/components/scalable.dart';
import 'package:app/player/presentation/video_player/components/seek_area/widget.dart';
import 'package:app/player/presentation/video_player/components/show_on_mouse_hover.dart';
import 'package:app/player/presentation/video_player/components/video_play_pause_loader.dart';
import 'package:app/player/presentation/video_player/components/video_seek_bar.dart';
import 'package:app/player/presentation/video_player/components/video_timer.dart';
import 'package:app/player/presentation/video_player/typedefs.dart';
import 'package:app/player/presentation/video_player/wm.dart';
import 'package:app/player/utils/pointer_devices_accuracy.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:video_player/video_player.dart';

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
          onPopInvokedWithResult: wm.handlePopInvoked,
          child: const Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [_Gestures(child: _Player()), _Controls()],
            ),
          ),
        ),
      ),
    );
  }
}

class _Gestures extends StatelessWidget {
  const _Gestures({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: context.wm.shortcuts,
      child: Focus(
        autofocus: true,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([
                context.wm.maxScale,
                context.wm.scaleAnchors,
              ]),
              builder:
                  (context, _) => Scalable(
                    maxScale: context.wm.maxScale.value,
                    anchors: context.wm.scaleAnchors.value,
                    child: child,
                  ),
            ),
            GestureDetector(
              supportedDevices: PointerDevicesAccuracy.accurateDevices,
              onTap: context.wm.handleAccurateTap,
              onDoubleTap: context.wm.handleAccurateDoubleTap,
            ),
            GestureDetector(
              supportedDevices: PointerDevicesAccuracy.inaccurateDevices,
              onTap: context.wm.handleInaccurateTap,
            ),
            Row(
              children: [
                _buildSeekArea(context, type: SeekType.rewind),
                _buildSeekArea(context, type: SeekType.fastForward),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekArea(BuildContext context, {required SeekType type}) {
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
      decoration: BoxDecoration(color: ColorScheme.of(context).surface),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Center(
            child: ListenableBuilder(
              listenable: context.wm.videoController.aspectRatio,
              builder:
                  (context, _) => AspectRatio(
                    aspectRatio: context.wm.videoController.aspectRatio.value,
                    child: ValueListenableBuilder(
                      valueListenable: context.wm.videoController.inner,
                      builder:
                          (context, innerController, _) =>
                              innerController == null
                                  ? const SizedBox.shrink()
                                  : VideoPlayer(innerController),
                    ),
                  ),
            ),
          ),
          const _Caption(),
          ListenableBuilder(
            listenable: context.wm.controlsVisibilityController,
            builder:
                (context, _) => AnimatedVisibility.emphasized(
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
        top: false,
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedSize(
                alignment: Alignment.bottomCenter,
                duration: Durations.medium2,
                curve: Easing.standard,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: AppBarTheme.of(context).toolbarHeight!,
                    child: AppBar(
                      forceMaterialTransparency: true,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Title(context.wm.title),
                          _Title(
                            context.wm.subtitle,
                            style: TextTheme.primaryOf(context).titleMedium,
                          ),
                        ],
                      ),
                      actions: const [_ShareButton(), _MenuButton()],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkipButton(
                  icon: const Icon(Icons.skip_previous_outlined),
                  onPressed: context.wm.onPreviousPressed,
                ),
                const SizedBox(width: 48),
                VideoPlayPauseLoader(
                  videoController: context.wm.videoController,
                ),
                const SizedBox(width: 48),
                _SkipButton(
                  icon: const Icon(Icons.skip_next_outlined),
                  onPressed: context.wm.onNextPressed,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSize(
                alignment: Alignment.topCenter,
                duration: Durations.medium2,
                curve: Easing.standard,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            VideoTimer(
                              videoController: context.wm.videoController,
                            ),
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
                            if (context.wm.showFullscreenButton)
                              FullscreenButton(
                                controller: context.wm.fullscreenController,
                              ),
                          ],
                        ),
                        VideoSeekBar(
                          videoController: context.wm.videoController,
                          onPositionChangeStart:
                              context.wm.handlePositionChangeStart,
                          onPositionChangeEnd:
                              context.wm.handlePositionChangeEnd,
                        ),
                      ],
                    ),
                  ),
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
  const _Title(this.data, {this.style});

  final ValueListenable<String> data;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: data,
      builder:
          (context, data, _) => AnimatedSwitcher(
            switchInCurve: Easing.standard,
            switchOutCurve: Easing.standard.flipped,
            duration: Durations.medium2,
            child: Text(data, key: Key(data), style: style),
          ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.onSharePressed,
      builder:
          (context, onSharePressed, _) => IconButton(
            icon: Icon(Icons.adaptive.share_outlined),
            onPressed: onSharePressed,
          ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.onMenuPressed,
      builder:
          (context, _) => IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: context.wm.onMenuPressed.value,
          ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed, required this.icon});

  final ValueListenable<VoidCallback?> onPressed;

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: onPressed,
      builder:
          (context, _) => IconButton.filledTonal(
            iconSize: 36,
            onPressed: onPressed.value,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                ColorScheme.of(context).secondaryContainer,
              ),
            ),
            icon: icon,
          ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.videoController.caption,
      builder: (context, caption, _) {
        if (caption.text.isEmpty) return const SizedBox.shrink();

        final TextStyle displaySmall = TextTheme.of(context).displaySmall!;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Builder(
                  builder: (context) {
                    const breakpointExpanded = Breakpoint(
                      beginWidth: 840,
                      andUp: true,
                    );
                    final Breakpoint? breakpoint =
                        Breakpoint.activeBreakpointIn(context, const [
                          Breakpoints.standard,
                          breakpointExpanded,
                          Breakpoints.largeAndUp,
                        ]);
                    return AnimatedSwitcher(
                      switchInCurve: Easing.standard,
                      switchOutCurve: Easing.standard.flipped,
                      duration: Durations.medium2,
                      child: Text(
                        caption.text,
                        key: ValueKey(breakpoint),
                        style: switch (breakpoint) {
                          Breakpoints.largeAndUp =>
                            TextTheme.of(context).displayMedium,
                          breakpointExpanded => displaySmall.copyWith(
                            fontSize: 28,
                          ),
                          _ => displaySmall.copyWith(fontSize: 22),
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
