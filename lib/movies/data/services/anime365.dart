import 'dart:ui';

import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';
import 'package:app/movies/data/services/service.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/domain/models/watch_list_element.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/player/player.dart';

class MoviesServiceAnime365 implements MoviesService {
  MoviesServiceAnime365({
    required CookieManager cookieManager,
    required NetworkService networkService,
  })  : _cookieManager = cookieManager,
        _networkService = networkService;

  final CookieManager _cookieManager;

  final NetworkService _networkService;

  int? _upNextMaxPage;

  @override
  Future<List<MovieBaseData>> getMovies({
    MoviesOrder order = MoviesOrder.byPopularity,
    bool? isOngoing,
    String? query,
    int? limit,
    int? offset,
    List<WatchStatus> watchStatuses = const [],
  }) async {
    final ResponseData<Json> response = await _networkService.request<Json>(
      RequestData(
        uri: Uri(
          path: '/api/series',
          queryParameters: {
            'fields': 'id,titles,title,type,myAnimeListId,myAnimeListScore',
            'order': _convertMoviesOrderToJson(order),
            if (isOngoing != null) 'isAiring': isOngoing ? 1 : 0,
            if (query?.isNotEmpty ?? false) 'query': query,
            if (limit != null) 'limit': limit,
            if (offset != null) 'offset': offset,
            if (watchStatuses.isNotEmpty)
              'status': watchStatuses.map(_convertWatchStatusToJson).join(','),
          }.map((key, value) => MapEntry(key, value.toString())),
        ),
        method: RequestMethod.get,
      ),
    );

    final anime365Data =
        List<Json>.from(response.body['data']! as List<dynamic>);
    final List<int> shikimoriIds = anime365Data
        .map((movieJson) => movieJson['myAnimeListId']! as int)
        .toList(growable: false);
    final ResponseData<Json> shikimoriResponse = await _networkService.request(
      RequestData(
        uri: Uri(scheme: 'https', host: 'shikimori.one', path: '/api/graphql'),
        method: RequestMethod.post,
        body: {
          'query': '''
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
    return anime365Data.map(
      (movieJson) {
        final shikimoriId = (movieJson['myAnimeListId']! as int).toString();
        final shikimoriPoster =
            shikimoriMovies[shikimoriId]!['poster']! as Json;
        return MovieBaseData(
          id: movieJson['id']! as int,
          title: (movieJson['titles'] as Json?)?['ru'] as String? ??
              movieJson['title']! as String,
          poster: ImageData(
            resolutionsUris: {
              60: Uri.parse(shikimoriPoster['miniAltUrl']! as String),
              120: Uri.parse(shikimoriPoster['miniAlt2xUrl']! as String),
              160: Uri.parse(shikimoriPoster['previewAltUrl']! as String),
              225: Uri.parse(shikimoriPoster['mainAltUrl']! as String),
              320: Uri.parse(shikimoriPoster['previewAlt2xUrl']! as String),
              450: Uri.parse(shikimoriPoster['mainAlt2xUrl']! as String),
              double.infinity: Uri.parse(
                shikimoriPoster['originalUrl']! as String,
              ),
            },
          ),
          type: _convertJsonToMovieType(movieJson['type']! as String),
          score: movieJson['myAnimeListScore'] == '-1'
              ? null
              : double.parse(movieJson['myAnimeListScore']! as String),
        );
      },
    ).toList(growable: false);
  }

  @override
  Future<List<UpNextData>> getUpNext({required int page}) async {
    if (page != 1 && _upNextMaxPage != null && page > _upNextMaxPage!) {
      return const [];
    }

    final ResponseData<String> response = await _networkService.request(
      RequestData(
        uri: Uri(
          path: '/',
          queryParameters: {
            'ajax': 'm-index-personal-episodes',
            if (page != 1) 'pageP': page.toString(),
          },
        ),
        method: RequestMethod.get,
      ),
    );
    final Document document = parse(response.body);
    final Element upNextCard = document.querySelector(
      'div.body-container > '
      'div.container.section > '
      'div#m-index-personal-episodes',
    )!;
    final Element? pagerCard =
        upNextCard.querySelector('div.pager.card > ul.pagination');
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
        const posterUrlPrefix = 'background-image: url(\'';
        const posterUrlPostfix = '\');';
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
        late final MovieType type;
        if (tvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.tv;
        } else if (movieEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.movie;
        } else if (ovaEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.ova;
        } else if (onaEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.ona;
        } else if (specialEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.special;
        } else if (tvSpecialEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.tvSpecial;
        } else if (musicEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.music;
        } else if (pvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieType.preview;
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

        return UpNextData(
          movie: MovieBaseData(
            id: movieId,
            title: movieTitle,
            poster: ImageData(
              resolutionsUris: {
                140: Uri.parse(posterUrl),
                double.infinity: Uri.parse(
                  posterUrl.replaceFirst('140x140.1.', ''),
                ),
              },
            ),
            type: type,
          ),
          episode: EpisodeData(
            id: episodeId,
            type: type,
            number: episodeNumber,
          ),
        );
      },
    ).toList(growable: false);
  }

  @override
  Future<MovieDetailsData> getMovie(int id) async {
    final ResponseData<Json> anime365Response = await _networkService.request(
      RequestData(
        uri: Uri(
          path: '/api/series/$id',
          queryParameters: {
            'fields': 'url,titles,genres,posterUrl,numberOfEpisodes,episodes,'
                'descriptions,myAnimeListId,myAnimeListScore',
          },
        ),
        method: RequestMethod.get,
      ),
    );
    final anime365Data = anime365Response.body['data']! as Json;

    final ResponseData<Json> shikimoriResponse = await _networkService.request(
      RequestData(
        uri: Uri(scheme: 'https', host: 'shikimori.one', path: '/api/graphql'),
        method: RequestMethod.post,
        body: {
          'query': '''
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
            .first as Json;
    final shikimoriPoster = shikimoriData['poster']! as Json;
    final Map<num, Json> shikimoriEpisodePreviews =
        switch (shikimoriData['videos']) {
      final List<dynamic> videosJsons => {
          for (final Json videoJson in videosJsons
              .where(
                (videoJson) => (videoJson as Json)['kind'] == 'episode_preview',
              )
              .cast())
            num.tryParse(videoJson['name']! as String) ?? -1: videoJson,
        },
      _ => const {},
    };

    final Uri movieUri = Uri.parse(anime365Data['url']! as String);
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
            : (anime365Data['episodes']! as List<dynamic>).cast<Json>().map(
                (episodeJson) {
                  final num number = num.parse(
                    episodeJson['episodeInt']! as String,
                  );
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
                        : ImageData(
                            resolutionsUris: {
                              double.infinity: Uri.parse(previewUrl),
                            },
                          ),
                  );
                },
              ).toList(growable: false);
    final poster = ImageData(
      resolutionsUris: {
        60: Uri.parse(shikimoriPoster['miniAltUrl']! as String),
        120: Uri.parse(shikimoriPoster['miniAlt2xUrl']! as String),
        160: Uri.parse(shikimoriPoster['previewAltUrl']! as String),
        225: Uri.parse(shikimoriPoster['mainAltUrl']! as String),
        320: Uri.parse(shikimoriPoster['previewAlt2xUrl']! as String),
        450: Uri.parse(shikimoriPoster['mainAlt2xUrl']! as String),
        double.infinity: Uri.parse(shikimoriPoster['originalUrl']! as String),
      },
    );

    return MovieDetailsData(
      id: id,
      uri: movieUri,
      title: (anime365Data['titles']! as Json)['ru']! as String,
      genres: genres,
      poster: poster,
      previews: previewsAndEpisodes
          .where((episode) => episode.type == MovieType.preview)
          .toList(growable: false),
      episodesCount: episodesCount,
      episodes: previewsAndEpisodes
          .where((episode) => episode.type != MovieType.preview)
          .toList(growable: false),
      description: switch (anime365Data['descriptions']) {
        final List<dynamic> jsons => (jsons.first as Json)['value']! as String,
        _ => null,
      },
      score: anime365Data['myAnimeListScore'] == '-1'
          ? null
          : double.parse(anime365Data['myAnimeListScore']! as String),
    );
  }

  @override
  Future<List<VideoTranslationData>> getTranslations(Object episodeId) async {
    final ResponseData<Json> response = await _networkService.request(
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
    final data = response.body['data']! as Json;

    return (data['translations']! as List<dynamic>)
        .cast<Json>()
        .where(
          (translationJson) =>
              translationJson['isActive'] == 1 &&
              translationJson['type'] != 'voiceOther',
        )
        .map(
          (translationJson) => VideoTranslationData(
            id: translationJson['id']! as int,
            title: translationJson['authorsSummary']! as String,
            type: VideoTranslationType.valueOf(
              translationJson['typeKind']! as String,
            ),
            locale: Locale.fromSubtags(
              languageCode: translationJson['typeLang']! as String,
            ),
            qualityType: VideoQualityType.valueOf(
              translationJson['qualityType']! as String,
            ),
            authors: List.from(
              translationJson['authorsList']! as List<dynamic>,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<VideoData> getTranslationVideo(Object translationId) async {
    final ResponseData<Json> response = await _networkService.request(
      RequestData(
        uri: Uri(
          path: '/api/translations/embed/$translationId',
        ),
        method: RequestMethod.get,
      ),
    );
    final data = response.body['data']! as Json;

    final List<Json> downloadSourcesJsons =
        (data['download']! as List<dynamic>).cast();
    final List<Json> streamSourcesJsons =
        (data['stream']! as List<dynamic>).cast();
    return VideoData(
      download: {
        for (final Json sourceJson in downloadSourcesJsons)
          sourceJson['height']! as num: Uri.parse(sourceJson['url']! as String),
      },
      stream: {
        for (final Json sourceJson in streamSourcesJsons)
          sourceJson['height']! as num: Uri.parse(
            (sourceJson['urls']! as List<dynamic>).first as String,
          ),
      },
      subtitlesUri: switch (data['subtitlesUrl']) {
        final String url => Uri.tryParse(url),
        _ => null,
      },
    );
  }

  @override
  Future<void> saveTranslationWatched(Object translationId) {
    return _networkService.request<void>(
      RequestData(
        uri: Uri(path: '/translations/watched/$translationId'),
        method: RequestMethod.post,
        body: {
          'csrf': _cookieManager.cookie.value['csrf']?.valueDecoded,
        },
      ),
    );
  }

  @override
  Future<WatchListElementData> getWatchStatusDetails(Uri movieUri) async {
    final ResponseData<String> response = await _networkService.request(
      RequestData(
        uri: movieUri,
        method: RequestMethod.get,
      ),
    );
    final Document document = parse(response.body);
    final Element bodyContainer = document.querySelector('div.body-container')!;
    final Element animeListForm = bodyContainer.querySelector(
      'div.animelist_one_series > form#yw2',
    )!;

    final String? status = animeListForm
        .querySelector('select#UsersRates_status > option[selected="selected"]')
        ?.text;

    final String? scoreValue = animeListForm
        .querySelector(
          'select#UsersRates_score > option[selected="selected"]',
        )
        ?.attributes['value'];
    final int? score = scoreValue == null ? null : int.parse(scoreValue);

    final String? watchedEpisodesCountValue = animeListForm
        .querySelector(
          'input#UsersRates_episodes',
        )
        ?.attributes['value'];
    final int watchedEpisodesCount = watchedEpisodesCountValue == null
        ? 0
        : int.parse(watchedEpisodesCountValue);

    final String? episodesCountValue = animeListForm
        .querySelector(
          'input#UsersRates_episodes',
        )
        ?.attributes['max'];
    final int? episodesCount =
        episodesCountValue == null ? null : int.parse(episodesCountValue);

    return status == null
        ? const WatchListElementData(status: WatchStatus.none)
        : WatchListElementData(
            status: switch (status) {
              'Запланировано' => WatchStatus.planned,
              'Смотрю' => WatchStatus.watching,
              'Просмотрено' => WatchStatus.completed,
              'Отложено' => WatchStatus.onHold,
              'Брошено' => WatchStatus.dropped,
              final Object? unsupported => throw UnsupportedError(
                  'Unsupported movie status: $unsupported',
                ),
            },
            score: score,
            watchedEpisodesCount: watchedEpisodesCount,
            episodesCount: episodesCount,
          );
  }

  MovieType _convertJsonToMovieType(String json) {
    return switch (json) {
      'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieType.tv,
      'movie' => MovieType.movie,
      'ova' => MovieType.ova,
      'ona' => MovieType.ona,
      'special' => MovieType.special,
      'tv_special' => MovieType.tvSpecial,
      'cm' => MovieType.ad,
      'music' => MovieType.music,
      'preview' || 'pv' => MovieType.preview,
      final Object? unsupported => throw UnsupportedError(
          'Unsupported movie type: $unsupported',
        ),
    };
  }

  String _convertMoviesOrderToJson(MoviesOrder order) {
    return switch (order) {
      MoviesOrder.byScore => 'ranked',
      MoviesOrder.byPopularity => 'popularity',
      MoviesOrder.byName => 'name',
      MoviesOrder.byReleaseDate => 'aired_on',
      MoviesOrder.random => 'random',
    };
  }

  int _convertWatchStatusToJson(WatchStatus watchStatus) {
    return switch (watchStatus) {
      WatchStatus.planned => 0,
      WatchStatus.watching => 1,
      WatchStatus.completed => 2,
      WatchStatus.onHold => 3,
      WatchStatus.dropped => 4,
      WatchStatus.none => -1,
    };
  }
}
