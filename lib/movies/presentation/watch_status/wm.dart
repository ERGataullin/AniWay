import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/movies/presentation/watch_status/model.dart';
import 'package:app/movies/presentation/watch_status/widget.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

WatchStatusWM watchStatusWMFactory(BuildContext context) => WatchStatusWM(
  WatchStatusModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<MoviesRepository>(),
  ),
);

abstract interface class IWatchStatusWM implements IWidgetModel {
  GlobalKey<FormState> get formKey;

  TextEditingController get episodesController;

  TextEditingController get commentController;

  ValueListenable<int?> get score;

  ValueListenable<bool> get loading;

  WatchStatus get status;

  WatchStatus? get currentStatus;

  int? get episodesCountTotal;

  String? validateEpisodes(String? value);

  void handleStatusSelected(WatchStatus status);

  void handleScorePressed(int score);

  Future<void> handleDeletePressed();

  Future<void> handleSavePressed();
}

class WatchStatusWM extends WidgetModel<WatchStatusWidget, IWatchStatusModel>
    with ThemeWMMixin
    implements IWatchStatusWM {
  WatchStatusWM(super._model);

  @override
  final formKey = GlobalKey<FormState>();

  @override
  final episodesController = TextEditingController();

  @override
  final commentController = TextEditingController();

  @override
  final ValueNotifier<int?> score = ValueNotifier(null);

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  WatchStatus _status = WatchStatus.planned;
  @override
  WatchStatus get status => _status;

  @override
  WatchStatus? get currentStatus => widget.statusDetails.status;

  @override
  int? get episodesCountTotal => widget.movie.episodesCount;

  @override
  String? validateEpisodes(String? value) {
    if (episodesCountTotal == null) return null;
    if (value?.isEmpty ?? true) return null;
    return int.parse(value!) > episodesCountTotal!
        ? context.l10n.watchStatusEpisodesError(episodesCountTotal!)
        : null;
  }

  @override
  void handleStatusSelected(WatchStatus status) {
    _status = status;
  }

  @override
  void handleScorePressed(int score) {
    this.score.value = score;
  }

  @override
  Future<void> handleDeletePressed() async {
    const status = WatchStatusDetails(null);
    await _submit(status);
    if (!context.mounted) return;
    Navigator.pop(context, status);
  }

  @override
  Future<void> handleSavePressed() async {
    final status = WatchStatusDetails(
      _status,
      score: score.value,
      episodesCount: int.parse(episodesController.text),
      comment: commentController.text,
    );
    if (formKey.currentState!.validate()) {
      await _submit(status);
      if (!context.mounted) return;
      Navigator.pop(context, status);
    }
  }

  @override
  void initWidgetModel() {
    _status = widget.statusDetails.status ?? WatchStatus.planned;
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
    await model.save(movieId: widget.movie.id, status: watchStatusDetails);
  }
}
