import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/presentation/episodes/model.dart';

EpisodesWM episodesWMFactory(BuildContext context) => EpisodesWM(
      EpisodesModel(
        errorHandler: context.read<ErrorHandler>(),
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class IEpisodesWM implements IWidgetModel {
  ValueListenable<bool> get showLoader;

  ValueListenable<TabController?> get tabController;

  ValueListenable<List<String>> get tabsTexts;

  ValueListenable<String> get episodesLabel;

  ValueListenable<List<List<EpisodeData>>> get tabsEpisodes;

  String getEpisodeTitle(EpisodeData episode);

  void handleEpisodePressed(int episodeId);
}

class EpisodesWM extends WidgetModel<EpisodesWidget, IEpisodesModel>
    with L10nWMMixin, SingleTickerProviderWidgetModelMixin
    implements IEpisodesWM {
  EpisodesWM(super._model);

  static const int _groupSize = 25;

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  late final DynamicData<TabController?> tabController = DynamicData(
    () => _episodes.value.isEmpty
        ? null
        : TabController(
            length: (_episodes.value.length / _groupSize).ceil(),
            vsync: this,
          ),
  );

  @override
  late final DynamicData<List<String>> tabsTexts = DynamicData(
    trigger: _episodes,
    () => List.generate(
      (_episodes.value.length / _groupSize).ceil(),
      (index) {
        final List<EpisodeData> tabEpisodes = tabsEpisodes.value[index];
        return context.l10n.tabEpisodesText(
          tabEpisodes.first.number ?? 0,
          tabEpisodes.last.number ?? 0,
        );
      },
    ),
  );

  @override
  late final DynamicData<String> episodesLabel = DynamicData(
    trigger: l10n,
    () => l10n.value.episodesLabel,
  );

  late final DynamicData<List<EpisodeData>> _episodes = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.episodes ?? const [],
  );

  @override
  late final DynamicData<List<List<EpisodeData>>> tabsEpisodes = DynamicData(
    trigger: _episodes,
    () => List.generate(
      (_episodes.value.length / _groupSize).ceil(),
      (index) {
        final startIndex = index * _groupSize;
        final endIndex = math.min(
          _episodes.value.length - 1,
          index * _groupSize + _groupSize - 1,
        );
        return _episodes.value
            .getRange(startIndex, endIndex + 1)
            .toList(growable: false);
      },
    ),
  );

  @override
  String getEpisodeTitle(EpisodeData episodeData) {
    return context.l10n
        .movieEpisode(episodeData.type.name, episodeData.number ?? 0);
  }

  @override
  void handleEpisodePressed(int episodeId) {
    widget.onEpisodePressed(episodeId);
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _episodes.addListener(_handleEpisodesChanged);
    model.loadData(
      movieId: widget.movieId,
    );
  }

  @override
  void dispose() {
    episodesLabel.dispose();
    tabController
      ..value?.dispose()
      ..dispose();
    tabsTexts.dispose();
    _episodes.dispose();
    tabsEpisodes.dispose();
    super.dispose();
  }

  void _handleEpisodesChanged() {
    tabController
      ..value?.dispose()
      ..update();
  }
}
