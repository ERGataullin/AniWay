import 'dart:convert';

import 'package:core/core.dart';
import 'package:player/player.dart';

class Anime365PlayerDataSource implements PlayerDataSource {
  const Anime365PlayerDataSource({
    required Network network,
  }) : _network = network;

  final Network _network;

  @override
  Future<MovieDto> getMovie(Object id) async {
    final NetworkResponseData response = await _network.request(
      NetworkRequestData(
        uri: Uri(
          path: '/api/series/$id',
          queryParameters: {
            'fields': 'titles,episodes',
          },
        ),
        method: NetworkRequestMethodData.get,
      ),
    );

    final Map<String, dynamic> json =
        response.body['data'] as Map<String, dynamic>;
    return MovieDto(
      id: id,
      title: json['titles']['ru'] as String,
      episodes: (json['episodes'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> episodeJson) => EpisodeDto(
              id: id,
              type: episodeJson['episodeType'] as String,
              number: num.parse(episodeJson['episodeInt'] as String),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<List<VideoTranslationDto>> getTranslations(Object episodeId) async {
    final NetworkResponseData response = await _network.request(
      NetworkRequestData(
        uri: Uri(
          path: '/api/episodes/$episodeId',
          queryParameters: {
            'fields': 'translations',
          },
        ),
        method: NetworkRequestMethodData.get,
      ),
    );

    final Map<String, dynamic> json =
        response.body['data'] as Map<String, dynamic>;
    return (json['translations'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where(
          (translationJson) =>
              translationJson['isActive'] == 1 &&
              translationJson['type'] != 'voiceOther',
        )
        .map(
      (translationJson) {
        String title = translationJson['authorsSummary'] as String;
        if (title.contains('(')) {
          title = title.substring(0, title.indexOf('(') - 1);
        }

        return VideoTranslationDto(
          id: translationJson['id'] as Object,
          title: title,
          type: translationJson['typeKind'] as String,
          language: translationJson['typeLang'] as String,
          embedUrl: translationJson['embedUrl'] as String,
        );
      },
    ).toList(growable: false);
  }

  @override
  Future<VideoDto> getTranslationVideo(String embedUrl) async {
    final NetworkResponseData response = await _network.request(
      NetworkRequestData(
        uri: Uri.parse(embedUrl),
        method: NetworkRequestMethodData.get,
      ),
    );

    final Document document = parse(response.body as String);

    const String csrfPrefix = 'var YII_CSRF_TOKEN = "';
    String csrf = document.outerHtml.substring(
      document.outerHtml.indexOf(csrfPrefix) + csrfPrefix.length,
    );
    csrf = csrf.substring(0, csrf.indexOf('"'));

    final Element player = document.querySelector('video')!;
    final List<VideoSourceDto> sources =
        (jsonDecode(player.attributes['data-sources']!) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(
              (sourceJson) => VideoSourceDto(
                quality: sourceJson['height'].toString(),
                url: sourceJson['urls'].first as String,
              ),
            )
            .toList(growable: false);

    return VideoDto(
      csrf: csrf,
      sources: {
        for (final VideoSourceDto source in sources) source.quality: source,
      },
    );
  }
}
