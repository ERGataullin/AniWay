import 'package:core/core.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/seek_gesture_detector_side.dart';
import 'package:player/src/presentation/components/scalable/widget.dart';
import 'package:player/src/presentation/components/seek_gesture_detector/widget.dart';
import 'package:player/src/presentation/components/video_controls/widget_model.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

extension _VideoControlsContext on BuildContext {
  IVideoControlsWidgetModel get wm => read<IVideoControlsWidgetModel>();
}

class VideoControlsWidget extends ElementaryWidget<IVideoControlsWidgetModel> {
  const VideoControlsWidget({
    super.key,
    required this.controller,
    required this.title,
    this.preferences = const [],
    required this.child,
    WidgetModelFactory wmFactory = videoControlsWidgetModelFactory,
  }) : super(wmFactory);

  final VideoController controller;

  final String title;

  final List<MenuItemData> preferences;

  final Widget child;

  @override
  Widget build(IVideoControlsWidgetModel wm) {
    return Provider<IVideoControlsWidgetModel>.value(
      value: wm,
      child: _Theme(
        child: _MouseRegion(
          child: Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                _Gestures(
                  child: _Child(child: child),
                ),
                const _Controls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Theme extends StatelessWidget {
  const _Theme({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const Color background = Colors.black;
    final ThemeData theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        colorScheme: theme.colorScheme.copyWith(
          background: background,
          onBackground: Colors.white,
        ),
      ),
      child: child,
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: context.wm.onTapUp,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ValueListenableBuilder(
            valueListenable: context.wm.maxScale,
            child: child,
            builder: (context, maxScale, child) => ValueListenableBuilder(
              valueListenable: context.wm.scaleAnchors,
              builder: (context, scaleAnchors, ___) => ScalableWidget(
                maxScale: maxScale,
                anchors: scaleAnchors,
                child: child!,
              ),
            ),
          ),
          const Row(
            children: [
              _SeekGestureDetector(side: SeekGestureDetectorSide.left),
              _SeekGestureDetector(side: SeekGestureDetectorSide.right),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeekGestureDetector extends StatelessWidget {
  const _SeekGestureDetector({
    required this.side,
  });

  final SeekGestureDetectorSide side;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: SeekGestureDetectorWidget(
          side: side,
          callback: () => context.wm.onSeekGesture(side),
        ),
      ),
    );
  }
}

class _Child extends StatelessWidget {
  const _Child({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Center(
          child: child,
        ),
        FadeTransition(
          opacity: context.wm.fadeAnimation,
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
    return FadeTransition(
      opacity: context.wm.fadeAnimation,
      child: ValueListenableBuilder(
        valueListenable: context.wm.controlsIgnorePointer,
        builder: (context, ignorePointer, child) => IgnorePointer(
          ignoring: ignorePointer,
          child: child,
        ),
        child: const Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            _Top(),
            _PlayPauseButton(),
            _Bottom(),
          ],
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
        forceMaterialTransparency: true,
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
      child: VideoProgressIndicator(
        context.wm.controller,
        allowScrubbing: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
