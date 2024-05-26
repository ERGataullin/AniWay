import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/fullscreen/fullscreen_button.dart';
import 'package:player/src/presentation/components/scalable.dart';
import 'package:player/src/presentation/components/seek_area/widget.dart';
import 'package:player/src/presentation/components/video_player/widget_model.dart';
import 'package:player/src/presentation/components/video_timer.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

extension _VideoPlayerContext on BuildContext {
  IVideoPlayerWidgetModel get wm => read<IVideoPlayerWidgetModel>();
}

class VideoPlayerWidget extends ElementaryWidget<IVideoPlayerWidgetModel> {
  const VideoPlayerWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    this.preferences = const [],
    required this.onPreviousPressed,
    required this.onNextPressed,
    WidgetModelFactory wmFactory = videoPlayerWidgetModelFactory,
  }) : super(wmFactory);

  final VideoController controller;

  final String title;

  final String subtitle;

  final List<MenuItemData> preferences;

  final VoidCallback onPreviousPressed;

  final VoidCallback onNextPressed;

  @override
  Widget build(IVideoPlayerWidgetModel wm) {
    return Provider<IVideoPlayerWidgetModel>.value(
      value: wm,
      child: const _MouseRegion(
        child: Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              _Gestures(
                child: _Player(),
              ),
              _Controls(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MouseRegion extends StatelessWidget {
  const _MouseRegion({
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MouseCursor>(
      valueListenable: context.wm.cursor,
      builder: (context, cursor, ___) => MouseRegion(
        cursor: cursor,
        onHover: context.wm.onPointerHover,
        onExit: context.wm.onPointerExit,
        child: child,
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
        const Row(
          children: [
            _SeekArea(type: SeekType.rewind),
            _SeekArea(type: SeekType.fastForward),
          ],
        ),
      ],
    );
  }
}

class _SeekArea extends StatelessWidget {
  const _SeekArea({
    required this.type,
  });

  final SeekType type;

  @override
  Widget build(BuildContext context) {
    final ValueListenable<bool> enabled = switch (type) {
      SeekType.rewind => context.wm.rewindEnabled,
      SeekType.fastForward => context.wm.fastForwardEnabled,
    };
    return Expanded(
      child: ListenableBuilder(
        listenable: enabled,
        builder: (context, __) => SeekAreaWidget(
          type: type,
          enabled: enabled.value,
          onSeek: context.wm.onSeek,
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Center(
          child: ListenableBuilder(
            listenable: context.wm.aspectRatio,
            builder: (context, __) => AspectRatio(
              aspectRatio: context.wm.aspectRatio.value,
              child: VideoPlayer(context.wm.controller),
            ),
          ),
        ),
        AnimatedVisibility.emphasized(
          visible: context.wm.visible,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility.emphasized(
      visible: context.wm.visible,
      child: const Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          _Top(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreviousButton(),
              SizedBox(width: 64),
              _PlayPauseLoader(),
              SizedBox(width: 64),
              _NextButton(),
            ],
          ),
          _Bottom(),
        ],
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
        forceMaterialTransparency: true,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(),
            _Subtitle(),
          ],
        ),
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
      builder: (context, title, ___) => AnimatedSwitcher(
        switchInCurve: Easing.standard,
        duration: Durations.medium2,
        child: Text(
          title,
          key: Key(title),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: context.wm.subtitle,
      builder: (context, subtitle, ___) => AnimatedSwitcher(
        switchInCurve: Easing.standard,
        duration: Durations.medium2,
        child: Text(
          subtitle,
          key: Key(subtitle),
          style: Theme.of(context).primaryTextTheme.titleSmall,
        ),
      ),
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

class _PlayPauseLoader extends StatelessWidget {
  const _PlayPauseLoader();

  static Widget _animatedCrossFadeLayoutBuilder(
    Widget topChild,
    Key topChildKey,
    Widget bottomChild,
    Key bottomChildKey,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox(
          key: bottomChildKey,
          child: bottomChild,
        ),
        SizedBox(
          key: topChildKey,
          child: topChild,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double size = 48;
    return ValueListenableBuilder(
      valueListenable: context.wm.playPauseLoaderCallback,
      builder: (context, callback, ___) => IconButton.filledTonal(
        iconSize: size,
        onPressed: callback,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        icon: ValueListenableBuilder(
          valueListenable: context.wm.playPauseLoaderState,
          builder: (context, state, ___) => AnimatedCrossFade(
            alignment: Alignment.center,
            // TODO(ERGataullin): replace with Easing.emphasized
            firstCurve: Easing.standard,
            secondCurve: Easing.standard,
            duration: Durations.medium2,
            crossFadeState: state,
            layoutBuilder: _animatedCrossFadeLayoutBuilder,
            firstChild: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: context.wm.playPauseAnimation,
            ),
            secondChild: const CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VideoTimer(videoController: context.wm.controller),
                FullscreenButton(controller: context.wm.fullscreenController),
              ],
            ),
            const SizedBox(height: 4),
            const _SeekBar(),
          ],
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.positionValue,
      builder: (context, value, ___) => Slider.adaptive(
        value: value,
        onChangeStart: context.wm.onPositionChangeStart,
        onChangeEnd: context.wm.onPositionChangeEnd,
        onChanged: context.wm.onPositionChanged,
      ),
    );
  }
}

class _PreviousButton extends StatelessWidget {
  const _PreviousButton();

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: context.wm.onPreviousButtonPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      icon: const Icon(Icons.skip_previous),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton();

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: context.wm.onNextPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      icon: const Icon(Icons.skip_next),
    );
  }
}
