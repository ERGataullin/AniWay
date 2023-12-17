import 'package:core/core.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/scalable/widget.dart';
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
        child: _UserActivityListener(
          child: Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                _Child(child: child),
                const _Controls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserActivityListener extends StatelessWidget {
  const _UserActivityListener({
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MouseCursor>(
      valueListenable: context.wm.cursor,
      child: GestureDetector(
        onTapUp: context.wm.onTapUp,
        child: child,
      ),
      builder: (context, cursor, child) => MouseRegion(
        cursor: cursor,
        onHover: context.wm.onPointerHover,
        onExit: context.wm.onPointerExit,
        child: child,
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
    const Color background = Colors.black45;
    final ThemeData theme = Theme.of(context);

    return Theme(
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
      child: child,
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
    return ValueListenableBuilder(
      valueListenable: context.wm.maxScale,
      builder: (context, maxScale, ___) => ValueListenableBuilder(
        valueListenable: context.wm.scaleAnchors,
        builder: (context, scaleAnchors, ___) => ScalableWidget(
          maxScale: maxScale,
          anchors: scaleAnchors,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.wm.visible,
      child: const Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          _Top(),
          _PlayPauseLoader(),
          _Bottom(),
        ],
      ),
      builder: (context, visible, controls) => AnimatedSwitcher(
        switchInCurve: Easing.emphasizedDecelerate,
        // TODO(ERGataullin): replace with Easing.emphasized
        switchOutCurve: Easing.emphasizedAccelerate,
        duration: Durations.long2,
        reverseDuration: Durations.short4,
        child: visible ? controls : null,
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
          firstCurve: Easing.emphasizedDecelerate,
          secondCurve: Easing.emphasizedDecelerate,
          duration: Durations.short4,
          crossFadeState: state,
          layoutBuilder: _animatedCrossFadeLayoutBuilder,
          firstChild: const SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          ),
          secondChild: IconButton(
            onPressed: context.wm.onPlayPausePressed,
            icon: AnimatedIcon(
              size: size,
              icon: AnimatedIcons.play_pause,
              progress: context.wm.playPauseAnimation,
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
