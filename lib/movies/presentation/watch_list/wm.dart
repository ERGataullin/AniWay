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

  ValueListenable<bool> get loading;

  WatchStatus get status;

  WatchStatus get currentStatus;

  List<WatchStatus> get statuses;

  int? get episodesCount;

  void handleSelectedValue(WatchStatus status);

  void handleScorePressed(int score);

  void handleDeletePressed();

  void handleSavePressed();
}

class WatchListWM extends WidgetModel<WatchListWidget, IWatchListModel>
    with ThemeWMMixin
    implements IWatchListWM {
  WatchListWM(super._model);

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
  WatchStatus get currentStatus => widget.watchListElementData.status;

  @override
  List<WatchStatus> get statuses => WatchStatus.values
      .where((status) => status != WatchStatus.none)
      .toList(growable: false);

  @override
  int? get episodesCount => widget.movie.episodesCount;

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
    _submit(isDelete: true);
    Navigator.pop(context, const WatchStatusDetails(status: WatchStatus.none));
  }

  @override
  void handleSavePressed() {
    _submit();
    Navigator.pop(
      context,
      WatchStatusDetails(
        status: status,
        score: score.value,
        watchedEpisodesCount: int.parse(episodesController.text),
        comment: commentController.text,
      ),
    );
  }

  @override
  void initWidgetModel() {
    _selectedStatus = switch (widget.watchListElementData.status) {
      WatchStatus.none => WatchStatus.planned,
      final WatchStatus status => status,
    };
    episodesController.text =
        '${widget.watchListElementData.watchedEpisodesCount}';
    score.value = widget.watchListElementData.score;
    commentController.text = widget.watchListElementData.comment ?? '';
    super.initWidgetModel();
  }

  @override
  void dispose() {
    episodesController.dispose();
    score.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> _submit({bool isDelete = false}) async {
    loading.value = true;
    await model.saveWatchStatus(
      movieId: widget.movie.id,
      status: isDelete ? null : _selectedStatus,
      score: score.value!,
      episodes: int.parse(episodesController.text),
      comment: commentController.text,
    );
    loading.value = false;
  }
}
