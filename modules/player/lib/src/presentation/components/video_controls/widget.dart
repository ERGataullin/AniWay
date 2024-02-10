import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/side.dart';
import 'package:player/src/presentation/components/scalable/widget.dart';
import 'package:player/src/presentation/components/seek_gesture/widget.dart';
import 'package:player/src/presentation/components/video_controls/widget_model.dart';
import 'package:player/src/utils/video_controller.dart';

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
        fit: StackFit.expand,
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
              _SeekGesture(side: Side.left),
              _SeekGesture(side: Side.right),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeekGesture extends StatelessWidget {
  const _SeekGesture({
    required this.side,
  });

  final Side side;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SeekGestureWidget(
        side: side,
        videoController: context.wm.controller,
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
          _PlayPauseLoader(),
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
      children: <Widget>[
        Center(
          key: bottomChildKey,
          child: bottomChild,
        ),
        Center(
          key: topChildKey,
          child: topChild,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double size = 48;
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder(
        valueListenable: context.wm.playPauseLoaderState,
        builder: (context, state, ___) => AnimatedCrossFade(
          alignment: Alignment.center,
          // TODO(ERGataullin): replace with Easing.emphasized
          firstCurve: Easing.standard,
          secondCurve: Easing.standard,
          duration: Durations.medium2,
          crossFadeState: state,
          layoutBuilder: _animatedCrossFadeLayoutBuilder,
          firstChild: IconButton.filledTonal(
            onPressed: context.wm.onPlayPausePressed,
            icon: AnimatedIcon(
              size: size,
              icon: AnimatedIcons.play_pause,
              progress: context.wm.playPauseAnimation,
            ),
          ),
          secondChild: const SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
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
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Timer(),
            SizedBox(height: 4),
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
              color: Theme.of(context).colorScheme.secondary,
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 16,
                  color: Theme.of(context).colorScheme.shadow,
                ),
              ],
            ),
            children: [
              TextSpan(
                text: position,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onBackground,
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
