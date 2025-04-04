import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/movies/presentation/watch_status/model.dart';
import 'package:app/movies/presentation/watch_status/widget.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

WatchStatusWM watchStatusWMFactory(BuildContext context) => WatchStatusWM(
  WatchListModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class IWatchStatusWM implements IWidgetModel {
  TextEditingController get episodesController;

  TextEditingController get commentController;

  ValueListenable<int?> get score;

  ValueListenable<bool> get loading;

  WatchStatus get status;

  WatchStatus get currentStatus;

  List<WatchStatus> get statuses;

  int? get episodesCountTotal;

  void handleSelectedValue(WatchStatus status);

  void handleScorePressed(int score);

  void handleDeletePressed();

  void handleSavePressed();
}

class WatchStatusWM extends WidgetModel<WatchStatusWidget, IWatchListModel>
    with ThemeWMMixin
    implements IWatchStatusWM {
  WatchStatusWM(super._model);

  @override
  final episodesController = TextEditingController();

  @override
  final commentController = TextEditingController();

  @override
  final ValueNotifier<int?> score = ValueNotifier(null);

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  WatchStatus _selectedStatus = WatchStatus.planned;
  @override
  WatchStatus get status => _selectedStatus;

  @override
  WatchStatus get currentStatus => widget.statusDetails.status;

  @override
  List<WatchStatus> get statuses => WatchStatus.values
      .where((status) => status != WatchStatus.none)
      .toList(growable: false);

  @override
  int? get episodesCountTotal => widget.movie.episodesCount;

  @override
  void handleSelectedValue(WatchStatus status) {
    _selectedStatus = status;
  }

  @override
  void handleScorePressed(int score) {
    this.score.value = score;
  }

  @override
  void handleDeletePressed() {
    _submit(const WatchStatusDetails(WatchStatus.none));
    Navigator.pop(context, const WatchStatusDetails(WatchStatus.none));
  }

  @override
  void handleSavePressed() {
    _submit(
      WatchStatusDetails(
        _selectedStatus,
        score: score.value,
        episodesCount: int.parse(episodesController.text),
        comment: commentController.text,
      ),
    );
    Navigator.pop(
      context,
      WatchStatusDetails(
        status,
        score: score.value,
        episodesCount: int.parse(episodesController.text),
        comment: commentController.text,
      ),
    );
  }

  @override
  void initWidgetModel() {
    _selectedStatus = switch (widget.statusDetails.status) {
      WatchStatus.none => WatchStatus.planned,
      final WatchStatus status => status,
    };
    episodesController.text = '${widget.statusDetails.episodesCount}';
    score.value = widget.statusDetails.score;
    commentController.text = widget.statusDetails.comment ?? '';
    super.initWidgetModel();
  }

  @override
  void dispose() {
    loading.dispose();
    episodesController.dispose();
    score.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(WatchStatusDetails watchStatusDetails) async {
    loading.value = true;
    await model.saveWatchStatus(
      movieId: widget.movie.id,
      watchStatusDetails: watchStatusDetails,
    );
    loading.value = false;
  }
}
