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

  ValueListenable<List<EpisodeData>> get episodes;

  ValueListenable<List<List<EpisodeData>>> get tabEpisodes;

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
    () => episodes.value.isEmpty
        ? null
        : TabController(
            length: (episodes.value.length / _groupSize).ceil(),
            vsync: this,
          ),
  );

  @override
  late final DynamicData<List<String>> tabsTexts = DynamicData(
    trigger: episodes,
    () => List.generate(
      (episodes.value.length / _groupSize).ceil(),
      (index) {
        final startIndex = index * _groupSize;
        final endIndex = math.min(
          episodes.value.length - 1,
          index * _groupSize + _groupSize - 1,
        );
        return '${episodes.value[startIndex].number}-'
            '${episodes.value[endIndex].number}';
      },
    ),
  );

  @override
  late final DynamicData<List<EpisodeData>> episodes = DynamicData(
    trigger: model.movie,
    () => model.movie.value?.episodes ?? const [],
  );

  @override
  late final DynamicData<List<List<EpisodeData>>> tabEpisodes = DynamicData(
    trigger: episodes,
    () => List.generate(
      (episodes.value.length / _groupSize).ceil(),
      (index) {
        final startIndex = index * _groupSize;
        final endIndex = math.min(
          episodes.value.length - 1,
          index * _groupSize + _groupSize - 1,
        );
        return episodes.value
            .getRange(startIndex, endIndex + 1)
            .toList(growable: false);
      },
    ),
  );

  @override
  void handleEpisodePressed(int episodeId) {
    widget.onEpisodePressed(episodeId);
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    episodes.addListener(_handleEpisodesChanged);
    model.loadData(
      movieId: widget.movieId,
    );
  }

  @override
  void dispose() {
    tabController
      ..value?.dispose()
      ..dispose();
    tabsTexts.dispose();
    episodes.dispose();
    super.dispose();
  }

  void _handleEpisodesChanged() {
    tabController
      ..value?.dispose()
      ..update();
  }
}
