import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/presentation/components/up_next/model.dart';
import 'package:movies/src/presentation/components/up_next/widget.dart';

UpNextWM upNextWMFactory(BuildContext context) => UpNextWM(
      UpNextModel(
        context.read<ErrorHandler>(),
        posterBaseUri: context.read<Network>().baseUri,
      ),
    );

abstract interface class IUpNextWM implements IWidgetModel {
  ValueListenable<ImageProvider> get poster;

  ValueListenable<String> get title;

  ValueListenable<String> get episode;
}

class UpNextWM extends WidgetModel<UpNextWidget, IUpNextModel>
    implements IUpNextWM {
  UpNextWM(super._model);

  @override
  final ValueNotifier<ImageProvider> poster = ValueNotifier(
    const NetworkImage(''),
  );

  @override
  final ValueNotifier<String> episode = ValueNotifier('');

  @override
  ValueListenable<String> get title => model.title;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..posterUri.addListener(_updatePosterUrl)
      ..episodeType.addListener(_updateStatus)
      ..episodeNumber.addListener(_updateStatus)
      ..upNext = widget.upNext;
  }

  @override
  void didChangeDependencies() {
    _updateStatus();
  }

  @override
  void didUpdateWidget(UpNextWidget oldWidget) {
    model.upNext = widget.upNext;
  }

  @override
  void dispose() {
    super.dispose();
    model
      ..posterUri.removeListener(_updatePosterUrl)
      ..episodeType.removeListener(_updateStatus)
      ..episodeNumber.removeListener(_updateStatus);
    poster.dispose();
    episode.dispose();
  }

  void _updatePosterUrl() {
    poster.value = NetworkImage(model.posterUri.value.toString());
  }

  void _updateStatus() {
    episode.value = context.localizations.upNextStatus(
      model.episodeType.value.name,
      model.episodeNumber.value ?? 0,
    );
  }
}
