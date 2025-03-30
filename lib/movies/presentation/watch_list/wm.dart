import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/movies/presentation/watch_list/model.dart';
import 'package:app/movies/presentation/watch_list/widget.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

WatchListWM watchListWMFactory(BuildContext context) => WatchListWM(
  WatchListModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class IWatchListWM implements IWidgetModel {
  TextEditingController get episodesController;

  TextEditingController get commentController;

  ValueListenable<int?> get score;

  WatchStatusDetails get watchListelementData;

  void handleSelectedValue(WatchStatus status);

  void handleScorePressed(int score);

  void handleSavePressed();
}

class WatchListWM extends WidgetModel<WatchListWidget, IWatchListModel>
    with ThemeWMMixin
    implements IWatchListWM {
  WatchListWM(super._model);
  @override
  WatchStatusDetails get watchListelementData => widget.watchListElementData;

  @override
  final episodesController = TextEditingController();

  @override
  final commentController = TextEditingController();

  @override
  final ValueNotifier<int?> score = ValueNotifier(null);

  WatchStatus _selectedStatus = WatchStatus.planned;

  @override
  void handleSelectedValue(WatchStatus status) {
    _selectedStatus = status;
  }

  @override
  void handleScorePressed(int score) {
    this.score.value = score;
  }

  @override
  void handleSavePressed() {
    _submit();
  }

  @override
  void initWidgetModel() {
    //episodesController.text =
    //    widget.watchListElementData?.watchedEpisodesCount.toString() ?? '';
    super.initWidgetModel();
  }

  Future<void> _submit() async {
    await model.saveWatchStatus(
      movieId: widget.movieId,
      status: _selectedStatus,
      score: score.value!,
      episodes: int.parse(episodesController.text),
      comment: commentController.text,
    );
  }
}
