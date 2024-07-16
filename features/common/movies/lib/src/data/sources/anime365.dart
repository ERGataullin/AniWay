import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/data/dto/episode.dart';
import 'package:movies/src/data/dto/movie_player.dart';
import 'package:player/player.dart';

class Anime365MoviesDataSource implements MoviesDataSource {
  Anime365MoviesDataSource({
    required CookieManager cookieManager,
    required Network network,
  })  : _cookieManager = cookieManager,
        _network = network;

  final CookieManager _cookieManager;

  final Network _network;

  int? _upNextMaxPage;

  @override
  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    int? limit,
    int? offset,
    List<String?> watchStatus = const [],
  }) async {
    final ResponseData response = await _network.request(
      RequestData(
        uri: Uri(
          path: '/api/series',
          queryParameters: {
            'fields': 'id,titles,posterUrl,type,myAnimeListScore',
            if (order != null) 'order': order,
            if (query != null) 'query': query,
            if (limit != null) 'limit': limit,
            if (offset != null) 'offset': offset,
          }.map((key, value) => MapEntry(key, value.toString())),
        ),
        method: RequestMethod.get,
      ),
    );

    return response.body['data'].cast<Map<String, dynamic>>()
        as List<Map<String, dynamic>>;
  }

  @override
  Future<List<Map<String, dynamic>>> getUpNext({required int page}) async {
    if (page != 1 && _upNextMaxPage != null && page > _upNextMaxPage!) {
      return const [];
    }

    final ResponseData response = await _network.request(
      RequestData(
        uri: Uri(
          path: '/',
          queryParameters: {
            'ajax': 'm-index-personal-episodes',
            'pageP': page.toString(),
          },
        ),
        method: RequestMethod.get,
      ),
    );
    final Document document = parse(response.body as String);
    final Element upNextCard = document.querySelector(
      'div.body-container > '
      'div.container.section > '
      'div#m-index-personal-episodes',
    )!;
    _upNextMaxPage = upNextCard
            .querySelector('div.pager.card > ul.pagination')!
            .children
            .length -
        4;
    final Element upNextItemsContainer = upNextCard.querySelector(
      // Items card
      // ignore: lines_longer_than_80_chars
      'div.m-new-episodes.m-missed-episodes.card.collection.with-header.z-depth-1 > '
      // Up next items
      'div.row > div.items', // up next items
    )!;

    return upNextItemsContainer.children.map(
      (itemElement) {
        final Element a = itemElement.querySelector('a[href]')!;
        final Uri hrefUri = Uri.parse(a.attributes['href']!);

        final String moviePathSegment = hrefUri.pathSegments[1];
        final int movieId = int.parse(
          moviePathSegment.substring(
            moviePathSegment.lastIndexOf('-') + 1,
          ),
        );
        final String movieTitle = a.nodes[1].text!
            .split(' ')
            .where((part) => part.isNotEmpty)
            .join(' ');
        final String posterStyle = itemElement
            .querySelector('div.circle[style]')!
            .attributes['style']!;
        const String posterUrlPrefix = 'background-image: url(\'';
        const String posterUrlPostfix = '\');';
        String posterUrl = posterStyle.substring(
          posterStyle.indexOf(posterUrlPrefix) + posterUrlPrefix.length,
        );
        posterUrl = posterUrl
            .substring(0, posterUrl.indexOf(posterUrlPostfix))
            .replaceFirst('140x140.1.', '');

        final String episodePathSegment = hrefUri.pathSegments[2];
        final int episodeId = int.parse(
          episodePathSegment.substring(
            episodePathSegment.lastIndexOf('-') + 1,
          ),
        );
        final String episodeTitle = a.children[0].text;
        final RegExp episodeNumberPattern = RegExp(r'\d+(\.\d)?');
        final RegExp tvEpisodeTitlePattern = RegExp(
          '^${episodeNumberPattern.pattern} серия\$',
        );
        final RegExp movieEpisodeTitlePattern = RegExp(
          '^Фильм( ${episodeNumberPattern.pattern} серия)?\$',
        );
        final RegExp ovaEpisodeTitlePattern = RegExp(
          '^OVA( ${episodeNumberPattern.pattern} серия)?\$',
        );
        final RegExp onaEpisodeTitlePattern = RegExp(
          '^ONA( ${episodeNumberPattern.pattern} серия)?\$',
        );
        final RegExp specialEpisodeTitlePattern = RegExp(
          '^SP( ${episodeNumberPattern.pattern} серия)?\$',
        );
        final RegExp tvSpecialEpisodeTitlePattern = RegExp(
          '^TV SP( ${episodeNumberPattern.pattern} серия)?\$',
        );
        final RegExp musicEpisodeTitlePattern = RegExp(r'^Музыкальное видео$');
        final RegExp pvEpisodeTitlePattern = RegExp(r'^Проморолик$');
        late final String episodeType;
        if (tvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'tv';
        } else if (movieEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'movie';
        } else if (ovaEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'ova';
        } else if (onaEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'ona';
        } else if (specialEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'special';
        } else if (tvSpecialEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'tv_special';
        } else if (musicEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'music';
        } else if (pvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'pv';
        }
        final Iterable<RegExpMatch> episodeNumberMatches =
            episodeNumberPattern.allMatches(episodeTitle);
        final num? episodeNumber = episodeNumberMatches.isEmpty
            ? null
            : num.parse(
                episodeTitle.substring(
                  episodeNumberMatches.single.start,
                  episodeNumberMatches.single.end,
                ),
              );

        return {
          'movie': {
            'id': movieId,
            'titles': {
              'ru': movieTitle,
            },
            'posterUrl': posterUrl,
          },
          'episode': {
            'id': episodeId,
            'type': episodeType,
            'number': episodeNumber,
          },
        };
      },
    ).toList(growable: false);
  }

  @override
  Future<MoviePlayerDto> getPlayerMovie(int id) async {
    final ResponseData response = await _network.request(
      RequestData(
        uri: Uri(
          path: '/api/series/$id',
          queryParameters: {
            'fields': 'titles,episodes',
          },
        ),
        method: RequestMethod.get,
      ),
    );

    final Map<String, dynamic> json =
        response.body['data'] as Map<String, dynamic>;
    return MoviePlayerDto(
      id: id,
      title: json['titles']['ru'] as String,
      episodes: (json['episodes'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> episodeJson) => EpisodeDto(
              id: episodeJson['id'] as int,
              type: episodeJson['episodeType'] as String,
              number: num.parse(episodeJson['episodeInt'] as String),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<List<VideoTranslationDto>> getTranslations(Object episodeId) async {
    final ResponseData response = await _network.request(
      RequestData(
        uri: Uri(
          path: '/api/episodes/$episodeId',
          queryParameters: {
            'fields': 'translations',
          },
        ),
        method: RequestMethod.get,
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
          id: translationJson['id'] as int,
          title: title,
          type: translationJson['typeKind'] as String,
          language: translationJson['typeLang'] as String,
        );
      },
    ).toList(growable: false);
  }

  @override
  Future<VideoDto> getTranslationVideo(Object translationId) async {
    final ResponseData response = await _network.request(
      RequestData(
        uri: Uri(
          path: '/api/translations/embed/$translationId',
        ),
        method: RequestMethod.get,
      ),
    );

    final Iterable<Map<String, dynamic>> downloadSourcesJsons =
        (response.body['data']['download'] as Iterable<dynamic>).cast();
    final Iterable<Map<String, dynamic>> streamSourcesJsons =
        (response.body['data']['stream'] as Iterable<dynamic>).cast();
    return VideoDto(
      download: {
        for (final Map<String, dynamic> sourceJson in downloadSourcesJsons)
          sourceJson['height'] as num: sourceJson['url'] as String,
      },
      stream: {
        for (final Map<String, dynamic> sourceJson in streamSourcesJsons)
          sourceJson['height'] as num: sourceJson['urls'].first as String,
      },
      subtitlesUrl: response.body['data']['subtitlesUrl'] as String?,
    );
  }

  @override
  Future<void> saveTranslationWatched(Object translationId) {
    return _network.request(
      RequestData(
        uri: Uri(path: '/translations/watched/$translationId'),
        method: RequestMethod.post,
        body: {'csrf': _cookieManager.csrf},
      ),
    );
  }
}
