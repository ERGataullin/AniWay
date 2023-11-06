import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_watch_status.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/components/up_next/model.dart';
import 'package:movies/src/presentation/components/up_next/widget.dart';
import 'package:provider/provider.dart';

UpNextWidgetModel upNextWidgetModelFactory(BuildContext context) =>
    UpNextWidgetModel(
      UpNextModel(
        context.read<ErrorHandler>(),
      ),
      webResourcesBaseUri: context.read<Network>().baseUri,
    );

abstract interface class IUpNextWidgetModel implements IWidgetModel {
  ValueListenable<String> get posterUrl;

  ValueListenable<String> get title;

  ValueListenable<String> get status;
}

class UpNextWidgetModel extends WidgetModel<UpNextWidget, IUpNextModel>
    implements IUpNextWidgetModel {
  UpNextWidgetModel(
    super._model, {
    required Uri webResourcesBaseUri,
  }) : _webResourcesBaseUri = webResourcesBaseUri;

  @override
  final ValueNotifier<String> posterUrl = ValueNotifier('');

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> status = ValueNotifier('');

  final Uri _webResourcesBaseUri;

  UpNextData get _upNext => widget.upNext;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    posterUrl.value =
        _webResourcesBaseUri.resolveUri(_upNext.movie.posterUri).toString();
    title.value = _upNext.movie.title;
  }

  @override
  void didChangeDependencies() {
    status.value = context.localizations.componentsUpNextStatus(
      MovieWatchStatusData.watching.name,
      _upNext.episode.type.name,
      _upNext.episode.number ?? 0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    posterUrl.dispose();
    title.dispose();
    status.dispose();
  }
}
