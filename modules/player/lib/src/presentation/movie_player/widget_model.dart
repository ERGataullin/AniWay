import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/movie_player/model.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

MoviePlayerWidgetModel moviePlayerWidgetModelFactory(BuildContext context) =>
    MoviePlayerWidgetModel(
      MoviePlayerModel(
        context.read<ErrorHandler>(),
        service: context.read<PlayerService>(),
      ),
      fullscreen: context.read<Fullscreen>(),
    );

abstract interface class IMoviePlayerWidgetModel implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<List<MenuItemData>> get preferences;

  VideoController get controller;
}

class MoviePlayerWidgetModel
    extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    implements IMoviePlayerWidgetModel {
  MoviePlayerWidgetModel(
    super._model, {
    required Fullscreen fullscreen,
  }) : _fullscreen = fullscreen;

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<List<MenuItemData>> preferences = ValueNotifier(const []);

  @override
  final VideoController controller = VideoController();

  final Fullscreen _fullscreen;

  late final MovieData _movie;

  late final Map<VideoTranslationTypeData, List<VideoTranslationData>>
      _translations;

  late VideoTranslationTypeData _translationType;

  late VideoTranslationData _translation;

  late VideoData _video;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _fullscreen.request();
    controller.addListener(_onControllerValueChanged);
    _lockOrientation();
    _loadMovie();
    _loadTranslations();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    title.dispose();
    preferences.dispose();

    await Future.wait([
      controller.dispose(),
      _fullscreen.exit(),
      _unlockOrientation(),
    ]);
  }

  Future<void> _lockOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _unlockOrientation() {
    return SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> _loadMovie() async {
    _movie = await model.getMovie(widget.movieId);
    title.value = _movie.title;
  }

  Future<void> _loadTranslations() async {
    final List<VideoTranslationData> translationsList =
        await model.getTranslations(widget.episodeId);
    _translationType = VideoTranslationTypeData.raw;
    _translations = {
      for (final VideoTranslationTypeData type
          in VideoTranslationTypeData.values)
        type: translationsList
            .where((translation) => translation.type == type)
            .toList(growable: false),
    };
    _translation = _translations[_translationType]!.first;
    _updatePreferences();
    await _loadVideo();
  }

  Future<void> _loadVideo() async {
    _video = await model.getTranslationVideo(_translation.embedUri);
    controller.initialize(_video.sources.values.first.uri);
  }

  void _updatePreferences() {
    preferences.value = [
      MenuItemData.group(
        icon: Icons.type_specimen,
        label: context.localizations.moviePlayerPreferencesTranslationTypeLabel,
        children: _translations.keys
            .map(
              (type) => MenuItemData.group(
                selected: type == _translationType,
                label: context.localizations
                    .moviePlayerPreferencesTranslationType(type.toString()),
                onSelected: () {
                  _translationType = type;
                  _updatePreferences();
                },
                children: _getTranslationMenuItems(type: type),
              ),
            )
            .toList(growable: false),
      ),
      MenuItemData.group(
        icon: Icons.voice_chat,
        label: context.localizations.moviePlayerPreferencesTranslationLabel,
        children: _getTranslationMenuItems(),
      ),
    ];
  }

  List<MenuItemData> _getTranslationMenuItems({
    VideoTranslationTypeData? type,
  }) {
    return _translations[type ?? _translationType]!
        .map(
          (translation) => MenuItemData.single(
            selected: translation == _translation,
            label: translation.title,
            onSelected: () {
              _translation = translation;
              _loadVideo();
              _updatePreferences();
            },
          ),
        )
        .toList(growable: false);
  }

  Future<void> _onControllerValueChanged() async {
    final VideoPlayerValue value = controller.value;

    if (value.isCompleted) {
      await model.postTranslationWatched(_translation.id);
    }
  }
}
