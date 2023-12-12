import 'package:core/core.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
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
              fit: StackFit.expand,
              children: [
                child,
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

class _Controls extends StatelessWidget {
  const _Controls({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.wm.visible,
      builder: (context, visible, ___) => AnimatedSwitcher(
        switchInCurve: Easing.emphasizedDecelerate,
        // TODO(ERGataullin): replace with Easing.emphasized
        switchOutCurve: Easing.emphasizedAccelerate,
        duration: Durations.long2,
        reverseDuration: Durations.short4,
        child: visible
            ? const Stack(
                fit: StackFit.expand,
                children: [
                  _Top(),
                  _PlayPauseButton(),
                  _Bottom(),
                ],
              )
            : null,
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
      child: VideoProgressIndicator(
        context.wm.controller,
        allowScrubbing: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}