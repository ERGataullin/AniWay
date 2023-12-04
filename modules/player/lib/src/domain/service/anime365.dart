import 'package:core/core.dart';
import 'package:player/player.dart';

class Anime365PlayerService implements PlayerService {
  Anime365PlayerService({
    required Network network,
    required PlayerRepository repository,
  })  : _network = network,
        _repository = repository;

  final Network _network;

  final PlayerRepository _repository;

  @override
  Future<MovieData> getMovie(Object id) {
    return _repository.getMovie(id).then(MovieData.fromDto);
  }

  @override
  Future<List<VideoTranslationData>> getTranslations(Object episodeId) {
    return _repository
        .getTranslations(episodeId)
        .then((dtos) => dtos.map(VideoTranslationData.fromDto))
        .then((translations) => translations.toList(growable: false));
  }

  @override
  Future<VideoData> getTranslationVideo(Uri embedUri) {
    return _repository
        .getTranslationVideo(embedUri.toString())
        .then(VideoData.fromDto);
  }

  @override
  Future<void> postTranslationWatched(Object id) {
    return _network.request(
      NetworkRequestData(
        uri: Uri(
          path: '/translations/watched/$id',
        ),
        method: NetworkRequestMethodData.post,
        body: {
          'csrf': _network.csrf,
        },
      ),
    );
  }
}
