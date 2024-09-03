import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/src/presentation/episodes/model.dart';
import 'package:movies/src/presentation/episodes/widget.dart';

EpisodesWM episodesWMFactory(BuildContext context) => EpisodesWM(
      EpisodesModel(errorHandler: context.read<ErrorHandler>()),
    );

abstract interface class IEpisodesWM implements IWidgetModel {}

class EpisodesWM extends WidgetModel<EpisodesWidget, IEpisodesModel>
    with L10nWMMixin
    implements IEpisodesWM {
  EpisodesWM(super._model);
}
