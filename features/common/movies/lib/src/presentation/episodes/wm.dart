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
        repository: context.read<MoviesRepository>(),
      ),
    );

abstract interface class IEpisodesWM implements IWidgetModel {
  ValueListenable<bool> get loading;

  ValueListenable<TabController?> get tabController;

  ValueListenable<List<String>> get tabsTexts;

  ValueListenable<List<List<EpisodeData>>> get tabsEpisodes;

  void handleEpisodePressed(int episodeId);
}

class EpisodesWM extends WidgetModel<EpisodesWidget, IEpisodesModel>
    with L10nWMMixin, SingleTickerProviderWidgetModelMixin
    implements IEpisodesWM {
  EpisodesWM(super._model);

  static const int _groupSize = 24;

  @override
  ValueListenable<bool> get loading => model.loading;

  @override
  late final Computed<TabController?> tabController = Computed(
    () => _episodes.value.isEmpty
        ? null
        : TabController(
            length: (_episodes.value.length / _groupSize).ceil(),
            vsync: this,
          ),
  );

  @override
  late final Computed<List<String>> tabsTexts = Computed(
    trigger: _episodes,
    () => List.generate(
      (_episodes.value.length / _groupSize).ceil(),
      (index) {
        final List<EpisodeData> tabEpisodes = tabsEpisodes.value[index];
        return context.l10n.range(
          tabEpisodes.first.number ?? 0,
          tabEpisodes.last.number ?? 0,
        );
      },
    ),
  );

  late final Computed<List<EpisodeData>> _episodes = Computed(
    trigger: model.movie,
    () => model.movie.value?.episodes ?? const [],
  );

  @override
  late final Computed<List<List<EpisodeData>>> tabsEpisodes = Computed(
    trigger: _episodes,
    () => List.generate(
      (_episodes.value.length / _groupSize).ceil(),
      (index) {
        final int startIndex = index * _groupSize;
        final int endIndex = math.min(
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
  void handleEpisodePressed(int episodeId) {
    widget.onEpisodePressed(episodeId);
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _episodes.addListener(_handleEpisodesChanged);
    model.loadData(movieId: widget.movieId);
  }

  @override
  void dispose() {
    _episodes.dispose();
    tabController
      ..value?.dispose()
      ..dispose();
    tabsTexts.dispose();
    tabsEpisodes.dispose();
    super.dispose();
  }

  void _handleEpisodesChanged() {
    tabController
      ..value?.dispose()
      ..update();
  }
}
