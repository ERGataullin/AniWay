import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/service.dart';
import '/app/domain/services/network/service.dart';
import '/app/localizations.dart';
import '/modules/movies/domain/models/movie_watch_status.dart';
import '/modules/movies/domain/models/up_next.dart';
import '/modules/movies/presentation/components/up_next/model.dart';
import '/modules/movies/presentation/components/up_next/widget.dart';

UpNextWidgetModel upNextWidgetModelFactory(BuildContext context) =>
    UpNextWidgetModel(
      UpNextModel(
        context.read<ErrorHandleService>(),
      ),
      webResourcesBaseUri: context.read<NetworkService>().baseUri,
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
    status.value = context.localizations.moviesComponentsUpNextStatus(
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
