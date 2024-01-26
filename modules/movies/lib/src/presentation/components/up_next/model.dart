import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/src/domain/models/movie_episode.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class IUpNextModel implements ElementaryModel {
  ValueListenable<Uri> get posterUri;

  ValueListenable<String> get title;

  ValueListenable<MovieEpisodeTypeData> get episodeType;

  ValueListenable<num?> get episodeNumber;

  set upNext(UpNextData value);
}

class UpNextModel extends ElementaryModel implements IUpNextModel {
  UpNextModel(
    ErrorHandler errorHandler, {
    required Uri posterBaseUri,
  })  : _posterBaseUri = posterBaseUri,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<Uri> posterUri = ValueNotifier(Uri());

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<MovieEpisodeTypeData> episodeType = ValueNotifier(
    MovieEpisodeTypeData.unknown,
  );

  @override
  final ValueNotifier<num?> episodeNumber = ValueNotifier(null);

  @override
  set upNext(UpNextData value) {
    _upNext = value;
    posterUri.value = _posterBaseUri.resolveUri(_upNext.movie.posterUri);
    title.value = _upNext.movie.title;
    episodeType.value = _upNext.episode.type;
    episodeNumber.value = _upNext.episode.number;
  }

  final Uri _posterBaseUri;

  late UpNextData _upNext;

  @override
  void dispose() {
    super.dispose();
    posterUri.dispose();
    title.dispose();
    episodeType.dispose();
    episodeNumber.dispose();
  }
}
