import 'dart:io';

import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';
import 'package:app/movies/data/converters/anime365/watch_status.dart';
import 'package:app/movies/data/converters/anime365/watch_status_details.dart';
import 'package:app/movies/data/services/service.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/player/player.dart';

class MoviesServiceAnime365 implements MoviesService {
  MoviesServiceAnime365({
    required this._cookieManager,
    required this._networkService,
  });

  final CookieManager _cookieManager;

  final NetworkService _networkService;

  int? _upNextMaxPage;

  @override
  Future<List<MovieBaseData>> getMovies({
    MoviesOrder order = .byPopularity,
    bool? isOngoing,
    String? query,
    int? limit,
    int? offset,
    List<MovieType> typesExcluded = const [],
    List<WatchStatus> watchStatuses = const [],
  }) async {
    assert(typesExcluded.isEmpty || query == null);
    final ResponseData<Json> response = await _networkService.request<Json>(
      .new(
        method: .get,
        uri: .new(
          path: '/api/series',
          queryParameters: {
            'fields':
                'id,titles,title,type,myAnimeListId,myAnimeListScore,'
                'posterUrl,posterUrlSmall',
            'order': _convertMoviesOrderToJson(order),
            'isActive': 1,
            if (isOngoing != null) 'isAiring': isOngoing ? 1 : 0,
            if (typesExcluded.isNotEmpty)
              'chips':
                  'type!='
                  '${typesExcluded.map(_convertMovieTypeToJson).join(',')}',
            if (query?.isNotEmpty ?? false) 'query': query,
            'limit': ?limit,
            'offset': ?offset,
            if (watchStatuses.isNotEmpty)
              'chips': [
                'status',
                watchStatuses
                    .map(WatchStatusConverterAnime365.toJson)
                    .join(','),
              ].join('='),
          }.map((key, value) => .new(key, value.toString())),
        ),
      ),
    );

    final anime365Data = List<Json>.from(
      response.body['data']! as List<dynamic>,
    );
    final List<int> shikimoriIds = anime365Data
        .where((movieJson) => movieJson['myAnimeListId'] != 0)
        .map((movieJson) => movieJson['myAnimeListId']! as int)
        .toList(growable: false);
    final ResponseData<Json> shikimoriResponse = await _networkService.request(
      .new(
        method: .post,
        uri: .new(scheme: 'https', host: 'shikimori.io', path: '/api/graphql'),
        body: {
          'query':
              '''
            { 
              animes(ids: "${shikimoriIds.join(',')}", limit: 50 ) {
                id
                poster { 
                  miniAltUrl
                  miniAlt2xUrl
                  mainAltUrl
                  previewAltUrl
                  previewAlt2xUrl
                  mainAlt2xUrl
                  originalUrl
                }
              }
            }''',
        },
      ),
    );

    final shikimoriData = List<Json>.from(
      (shikimoriResponse.body['data']! as Json)['animes']! as List<dynamic>,
    );
    final Map<String, Json> shikimoriMovies = {
      for (final Json movie in shikimoriData) movie['id']! as String: movie,
    };
    return anime365Data
        .map((movieJson) {
          final Json? shikimoriPoster = switch (movieJson['myAnimeListId']) {
            final int id when id > 0 =>
              shikimoriMovies[id.toString()]?['poster'] as Json?,
            _ => null,
          };
          return MovieBaseData(
            id: movieJson['id']! as int,
            title:
                (movieJson['titles'] as Json?)?['ru'] as String? ??
                movieJson['title']! as String,
            poster: .new(
              resolutionsUris: shikimoriPoster == null
                  ? {
                      140: .parse(movieJson['posterUrlSmall']! as String),
                      double.infinity: .parse(
                        movieJson['posterUrl']! as String,
                      ),
                    }
                  : {
                      60: .parse(shikimoriPoster['miniAltUrl']! as String),
                      120: .parse(shikimoriPoster['miniAlt2xUrl']! as String),
                      160: .parse(shikimoriPoster['previewAltUrl']! as String),
                      225: .parse(shikimoriPoster['mainAltUrl']! as String),
                      320: .parse(
                        shikimoriPoster['previewAlt2xUrl']! as String,
                      ),
                      450: .parse(shikimoriPoster['mainAlt2xUrl']! as String),
                      double.infinity: .parse(
                        shikimoriPoster['originalUrl']! as String,
                      ),
                    },
            ),
            type: _convertJsonToMovieType(movieJson['type']! as String),
            score: movieJson['myAnimeListScore'] == '-1'
                ? null
                : .parse(movieJson['myAnimeListScore']! as String),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<UpNextData>> getUpNext({required int page}) async {
    if (page != 1 && _upNextMaxPage != null && page > _upNextMaxPage!) {
      return const [];
    }

    final ResponseData<String> response = await _networkService.request(
      .new(
        method: .get,
        uri: .new(
          path: '/',
          queryParameters: {
            'ajax': 'm-index-personal-episodes',
            if (page != 1) 'pageP': page.toString(),
          },
        ),
      ),
    );
    final Document document = parse(response.body);
    final Element upNextCard = document.querySelector(
      'div.body-container > '
      'div.container.section > '
      'div#m-index-personal-episodes',
    )!;
    final Element? pagerCard = upNextCard.querySelector(
      'div.pager.card > ul.pagination',
    );
    _upNextMaxPage = pagerCard == null ? 1 : pagerCard.children.length - 4;
    final Element upNextItemsContainer = upNextCard.querySelector(
      // Items card
      // ignore: lines_longer_than_80_chars
      'div.m-new-episodes.m-missed-episodes.card.collection.with-header.z-depth-1 > '
      // Up next items
      'div.row > div.items', // up next items
    )!;
    final episodeNumberPattern = RegExp(r'\d+(\.\d)?');
    final tvEpisodeTitlePattern = RegExp(
      '^${episodeNumberPattern.pattern} серия\$',
    );
    final movieEpisodeTitlePattern = RegExp(
      '^Фильм( ${episodeNumberPattern.pattern} серия)?\$',
    );
    final ovaEpisodeTitlePattern = RegExp(
      '^OVA( ${episodeNumberPattern.pattern} серия)?\$',
    );
    final onaEpisodeTitlePattern = RegExp(
      '^ONA( ${episodeNumberPattern.pattern} серия)?\$',
    );
    final specialEpisodeTitlePattern = RegExp(
      '^SP( ${episodeNumberPattern.pattern} серия)?\$',
    );
    final tvSpecialEpisodeTitlePattern = RegExp(
      '^TV SP( ${episodeNumberPattern.pattern} серия)?\$',
    );
    final musicEpisodeTitlePattern = RegExp(r'^Музыкальное видео$');
    final pvEpisodeTitlePattern = RegExp(r'^Проморолик$');

    return upNextItemsContainer.children
        .map((itemElement) {
          final Element a = itemElement.querySelector('a[href]')!;
          final Uri hrefUri = .parse(a.attributes['href']!);

          final String moviePathSegment = hrefUri.pathSegments[1];
          final int movieId = .parse(
            moviePathSegment.substring(moviePathSegment.lastIndexOf('-') + 1),
          );
          final String movieTitle = a.nodes[1].text!
              .split(' ')
              .where((part) => part.isNotEmpty)
              .join(' ');
          final String posterStyle = itemElement
              .querySelector('div.circle[style]')!
              .attributes['style']!;
          const posterUrlPrefix = 'background-image: url(\'';
          const posterUrlPostfix = '\');';
          String posterUrl = posterStyle.substring(
            posterStyle.indexOf(posterUrlPrefix) + posterUrlPrefix.length,
          );
          posterUrl = posterUrl.substring(
            0,
            posterUrl.indexOf(posterUrlPostfix),
          );

          final String episodePathSegment = hrefUri.pathSegments[2];
          final int episodeId = .parse(
            episodePathSegment.substring(
              episodePathSegment.lastIndexOf('-') + 1,
            ),
          );
          final String episodeTitle = a.children[0].text;
          late final MovieType type;
          if (tvEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .tv;
          } else if (movieEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .movie;
          } else if (ovaEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .ova;
          } else if (onaEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .ona;
          } else if (specialEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .special;
          } else if (tvSpecialEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .tvSpecial;
          } else if (musicEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .music;
          } else if (pvEpisodeTitlePattern.hasMatch(episodeTitle)) {
            type = .preview;
          }

          final Iterable<RegExpMatch> episodeNumberMatches =
              episodeNumberPattern.allMatches(episodeTitle);
          final num? episodeNumber = episodeNumberMatches.isEmpty
              ? null
              : .parse(
                  episodeTitle.substring(
                    episodeNumberMatches.single.start,
                    episodeNumberMatches.single.end,
                  ),
                );

          return UpNextData(
            movie: .new(
              id: movieId,
              title: movieTitle,
              poster: .new(
                resolutionsUris: {
                  140: .parse(posterUrl),
                  double.infinity: .parse(
                    posterUrl.replaceFirst('140x140.1.', ''),
                  ),
                },
              ),
              type: type,
            ),
            episode: .new(id: episodeId, type: type, number: episodeNumber),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<MovieDetailsData> getMovie(int id) async {
    final ResponseData<Json> anime365Response = await _networkService.request(
      .new(
        method: .get,
        uri: .new(
          path: '/api/series/$id',
          queryParameters: {
            'fields':
                'url,titles,genres,posterUrl,numberOfEpisodes,episodes,'
                'descriptions,myAnimeListId,myAnimeListScore',
          },
        ),
      ),
    );
    final anime365Data = anime365Response.body['data']! as Json;

    final ResponseData<Json> shikimoriResponse = await _networkService.request(
      .new(
        method: .post,
        uri: .new(scheme: 'https', host: 'shikimori.io', path: '/api/graphql'),
        body: {
          'query':
              '''
            { 
              animes(ids: "${anime365Data['myAnimeListId']}" ) {
                videos { name kind imageUrl }
                poster { 
                  miniAltUrl
                  miniAlt2xUrl
                  mainAltUrl
                  previewAltUrl
                  previewAlt2xUrl
                  mainAlt2xUrl
                  originalUrl
                }
              }
            }''',
        },
      ),
    );
    final shikimoriData =
        ((shikimoriResponse.body['data']! as Json)['animes']! as List<dynamic>)
                .first
            as Json;
    final shikimoriPoster = shikimoriData['poster']! as Json;
    final Map<num, Json> shikimoriEpisodePreviews =
        switch (shikimoriData['videos']) {
          final List<dynamic> videosJsons => {
            for (final Json videoJson
                in videosJsons
                    .where(
                      (videoJson) =>
                          (videoJson as Json)['kind'] == 'episode_preview',
                    )
                    .cast())
              .tryParse(videoJson['name']! as String) ?? -1: videoJson,
          },
          _ => const {},
        };

    final Uri movieUri = .parse(anime365Data['url']! as String);
    final List<String> genres = (anime365Data['genres']! as List<dynamic>)
        .cast<Json>()
        .map((genreJson) => genreJson['title']! as String)
        .toList(growable: false);
    final int? episodesCount = switch (anime365Data['numberOfEpisodes']) {
      final int numberOfEpisodes when numberOfEpisodes > 0 => numberOfEpisodes,
      _ => null,
    };
    final List<EpisodeData> previewsAndEpisodes =
        anime365Data['episodes'] == null
        ? const []
        : (anime365Data['episodes']! as List<dynamic>)
              .cast<Json>()
              .map((episodeJson) {
                final num number = .parse(episodeJson['episodeInt']! as String);
                var previewUrl =
                    shikimoriEpisodePreviews[number]?['imageUrl'] as String?;
                if (previewUrl?.startsWith('//') ?? false) {
                  previewUrl = 'https:$previewUrl';
                }
                return EpisodeData(
                  id: episodeJson['id']! as int,
                  type: _convertJsonToMovieType(
                    episodeJson['episodeType']! as String,
                  ),
                  number: number,
                  preview: previewUrl == null
                      ? null
                      : .new(
                          resolutionsUris: {
                            double.infinity: .parse(previewUrl),
                          },
                        ),
                );
              })
              .toList(growable: false);
    final poster = ImageData(
      resolutionsUris: {
        60: .parse(shikimoriPoster['miniAltUrl']! as String),
        120: .parse(shikimoriPoster['miniAlt2xUrl']! as String),
        160: .parse(shikimoriPoster['previewAltUrl']! as String),
        225: .parse(shikimoriPoster['mainAltUrl']! as String),
        320: .parse(shikimoriPoster['previewAlt2xUrl']! as String),
        450: .parse(shikimoriPoster['mainAlt2xUrl']! as String),
        double.infinity: .parse(shikimoriPoster['originalUrl']! as String),
      },
    );

    return .new(
      id: id,
      uri: movieUri,
      title: (anime365Data['titles']! as Json)['ru']! as String,
      genres: genres,
      poster: poster,
      previews: previewsAndEpisodes
          .where((episode) => episode.type == .preview)
          .toList(growable: false),
      episodesCount: episodesCount,
      episodes: previewsAndEpisodes
          .where((episode) => episode.type != .preview)
          .toList(growable: false),
      description: switch (anime365Data['descriptions']) {
        final List<dynamic> jsons => (jsons.first as Json)['value']! as String,
        _ => null,
      },
      score: anime365Data['myAnimeListScore'] == '-1'
          ? null
          : .parse(anime365Data['myAnimeListScore']! as String),
    );
  }

  @override
  Future<List<TranslationData>> getTranslations(Object episodeId) async {
    final ResponseData<Json> response = await _networkService.request(
      .new(
        method: .get,
        uri: .new(
          path: '/api/episodes/$episodeId',
          queryParameters: {'fields': 'translations'},
        ),
      ),
    );
    final data = response.body['data']! as Json;

    final spacesRegExp = RegExp(r'\s');
    return (data['translations']! as List<dynamic>)
        .cast<Json>()
        .where(
          (translationJson) =>
              translationJson['isActive'] == 1 &&
              translationJson['typeKind'] != 'voiceOth',
        )
        .map(
          (translationJson) => TranslationData(
            id: translationJson['id']! as int,
            uri: .parse(translationJson['url']! as String),
            title: switch (translationJson['authorsSummary']) {
              final String author when author.isNotEmpty => author,
              _ => 'Неизвестный',
            },
            type: .valueOf(translationJson['typeKind']! as String),
            locale: .fromSubtags(
              languageCode: translationJson['typeLang']! as String,
            ),
            qualityType: .valueOf(translationJson['qualityType']! as String),
            authors: (translationJson['authorsList']! as List<dynamic>)
                .cast<String>()
                .map(
                  (author) => TranslationAuthorData(
                    id: author.replaceAll(spacesRegExp, '').toLowerCase(),
                    title: author,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<VideoData> getTranslationVideo(int translationId) async {
    final ResponseData<Json> response = await _networkService.request(
      .new(
        method: .get,
        uri: .new(path: '/api/translations/embed/$translationId'),
      ),
    );
    final data = response.body['data']! as Json;

    final List<Json> downloadSourcesJsons = (data['download']! as List<dynamic>)
        .cast();
    final List<Json> streamSourcesJsons = (data['stream']! as List<dynamic>)
        .cast();
    return .new(
      download: {
        for (final Json sourceJson in downloadSourcesJsons)
          sourceJson['height']! as num: .parse(sourceJson['url']! as String),
      },
      stream: {
        for (final Json sourceJson in streamSourcesJsons)
          sourceJson['height']! as num: .parse(
            (sourceJson['urls']! as List<dynamic>).first as String,
          ),
      },
      captionsUri: switch (data['subtitlesVttUrl']) {
        final String url => .tryParse(url),
        _ => null,
      },
    );
  }

  @override
  Future<void> saveTranslationWatched(Object translationId) {
    return _networkService.request<void>(
      .new(
        method: .post,
        uri: .new(path: '/translations/watched/$translationId'),
        headers: const {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: {'csrf': _cookieManager.cookie.value['csrf']?.valueDecoded},
      ),
    );
  }

  @override
  Future<WatchStatusDetails> getWatchStatus(Uri movieUri) async {
    final ResponseData<String> response = await _networkService.request(
      .new(method: .get, uri: movieUri),
    );
    final Document document = parse(response.body);

    return WatchStatusDetailsConverterAnime365.fromHtml(
      document
          .querySelector('div.body-container')!
          .querySelector('div.animelist_one_series > form#yw2')!,
    );
  }

  @override
  Future<WatchStatusDetails> saveWatchStatus({
    required int movieId,
    required WatchStatusDetails status,
  }) async {
    final ResponseData<String> response = await _networkService.request(
      .new(
        method: .post,
        uri: .new(
          path: '/animelist/edit/$movieId',
          queryParameters: const {'mode': 'mini'},
        ),
        headers: const {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: {
          'csrf': _cookieManager.cookie.value['csrf']?.valueDecoded,
          ...WatchStatusDetailsConverterAnime365.toFormData(status),
        },
      ),
    );
    final Document document = parse(response.body);

    return WatchStatusDetailsConverterAnime365.fromHtml(
      document.documentElement!,
    );
  }

  MovieType _convertJsonToMovieType(String json) {
    return switch (json) {
      'tv' || 'tv_13' || 'tv_24' || 'tv_48' => .tv,
      'movie' => .movie,
      'ova' => .ova,
      'ona' => .ona,
      'special' => .special,
      'tv_special' => .tvSpecial,
      'cm' => .ad,
      'music' => .music,
      'preview' || 'pv' => .preview,
      final Object? unsupported => throw UnsupportedError(
        'Unsupported movie type: $unsupported',
      ),
    };
  }

  String _convertMovieTypeToJson(MovieType type) {
    return switch (type) {
      .tv => 'tv,tv_13,tv_24,tv_48',
      .movie => 'movie',
      .ova => 'ova',
      .ona => 'ona',
      .special => 'special',
      .tvSpecial => 'tv_special',
      .ad => 'cm',
      .music => 'music',
      .preview => 'preview,pv',
    };
  }

  String _convertMoviesOrderToJson(MoviesOrder order) {
    return switch (order) {
      .byScore => 'ranked',
      .byPopularity => 'popularity',
      .byName => 'name',
      .byReleaseDate => 'aired_on',
      .random => 'random',
    };
  }
}
