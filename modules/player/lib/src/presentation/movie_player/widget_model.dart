import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/movie_player/model.dart';
import 'package:player/src/utils/video_controller.dart';

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
  final ValueNotifier<List<MenuItemData>> preferences = ValueNotifier(const []);

  @override
  ValueListenable<String> get title => model.title;

  @override
  VideoController get controller => model.videoController;

  final Fullscreen _fullscreen;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..translations.addListener(_updatePreferences)
      ..translation.addListener(_updatePreferences)
      ..movieId = widget.movieId
      ..episodeId = widget.episodeId;
    // _fullscreen.request();
    _lockOrientation();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    model
      ..translations.removeListener(_updatePreferences)
      ..translation.removeListener(_updatePreferences);
    preferences.dispose();
    await Future.wait([
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

  void _updatePreferences() {
    preferences.value = [
      MenuItemData.group(
        icon: Icons.type_specimen,
        label: context.localizations.moviePlayerPreferencesTranslationTypeLabel,
        children: model.translations.value.keys
            .map(
              (type) => MenuItemData.group(
                selected: type == model.translation.value?.type,
                label: context.localizations
                    .moviePlayerPreferencesTranslationType(type.toString()),
                children: _getTranslationMenuItems(type: type),
              ),
            )
            .toList(growable: false),
      ),
      if (model.translation.value != null)
        MenuItemData.group(
          icon: Icons.voice_chat,
          label: context.localizations.moviePlayerPreferencesTranslationLabel,
          children: _getTranslationMenuItems(
            type: model.translation.value!.type,
          ),
        ),
    ];
  }

  List<MenuItemData> _getTranslationMenuItems({
    required VideoTranslationTypeData type,
  }) {
    return model.translations.value[type]!
        .map(
          (translation) => MenuItemData.single(
            selected: translation == model.translation.value,
            label: translation.title,
            onSelected: () => model.changeTranslation(translation),
          ),
        )
        .toList(growable: false);
  }
}
