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
    );

abstract interface class IMoviePlayerWidgetModel implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<List<MenuItemData>> get preferences;

  VideoController get controller;

  void onPreviousPressed();

  void onNextPressed();
}

class MoviePlayerWidgetModel
    extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    implements IMoviePlayerWidgetModel {
  MoviePlayerWidgetModel(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> subtitle = ValueNotifier('');

  @override
  final ValueNotifier<List<MenuItemData>> preferences = ValueNotifier(const []);

  @override
  VideoController get controller => model.videoController;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..initialize(
        movieId: widget.movieId,
        episodeId: widget.episodeId,
      )
      ..addListener(_onModelChanged);
    _lockOrientation();
  }

  @override
  void onPreviousPressed() {
    model.loadPreviousEpisode();
  }

  @override
  void onNextPressed() {
    model.loadNextEpisode();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    title.dispose();
    subtitle.dispose();
    preferences.dispose();
    await _unlockOrientation();
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

  void _onModelChanged() {
    title.value = model.movie.title;
    subtitle.value = PlayerLocalizations.of(context).moviePlayerEpisode(
      model.episode.type.name,
      model.episode.number,
    );
    preferences.value = [
      MenuItemData.group(
        icon: Icons.type_specimen,
        label: context.localizations.moviePlayerPreferencesTranslationTypeLabel,
        children: model.translations.keys
            .map(
              (type) => MenuItemData.group(
                selected: type == model.translation.type,
                label: context.localizations
                    .moviePlayerPreferencesTranslationType(type.toString()),
                children: _getTranslationMenuItems(type: type),
              ),
            )
            .toList(growable: false),
      ),
      MenuItemData.group(
        icon: Icons.voice_chat,
        label: context.localizations.moviePlayerPreferencesTranslationLabel,
        children: _getTranslationMenuItems(
          type: model.translation.type,
        ),
      ),
    ];
  }

  List<MenuItemData> _getTranslationMenuItems({
    required VideoTranslationTypeData type,
  }) {
    return model.translations[type]!
        .map(
          (translation) => MenuItemData.single(
            selected: translation == model.translation,
            label: translation.title,
            onSelected: () => model.translation = translation,
          ),
        )
        .toList(growable: false);
  }
}
