import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/movie_player/model.dart';
import 'package:player/src/utils/video_controller.dart';

MoviePlayerWM moviePlayerWMFactory(BuildContext context) => MoviePlayerWM(
      MoviePlayerModel(
        context.read<ErrorHandler>(),
        service: context.read<PlayerService>(),
      ),
    );

abstract interface class IMoviePlayerWM implements IWidgetModel {
  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<List<MenuItemData>> get preferences;

  VideoController get controller;

  void onPreviousPressed();

  void onNextPressed();
}

class MoviePlayerWM extends WidgetModel<MoviePlayerWidget, IMoviePlayerModel>
    with L10nWMMixin
    implements IMoviePlayerWM {
  MoviePlayerWM(super._model);

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
    if (!kIsWeb) {
      _lockOrientation();
    }
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
    if (!kIsWeb) {
      await _unlockOrientation();
    }
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
    subtitle.value = l10n.movieEpisode(
      model.episode.type.name,
      model.episode.number,
    );
    preferences.value = [
      MenuItemData.group(
        icon: Icons.type_specimen,
        label: l10n.translationTypeLabel,
        children: model.translations.keys
            .map(
              (type) => MenuItemData.group(
                selected: type == model.translation.type,
                label: l10n.translationType(type.toString()),
                children: _getTranslationMenuItems(type: type),
              ),
            )
            .toList(growable: false),
      ),
      MenuItemData.group(
        icon: Icons.voice_chat,
        label: l10n.translationLabel,
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
