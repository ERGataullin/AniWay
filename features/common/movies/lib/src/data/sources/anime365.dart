import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/data/dto/episode.dart';
import 'package:movies/src/data/dto/movie_base.dart';
import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/data/dto/movie_type.dart';
import 'package:movies/src/data/dto/movies_order.dart';
import 'package:movies/src/data/dto/up_next.dart';
import 'package:movies/src/data/dto/watch_list_element.dart';
import 'package:movies/src/data/dto/watch_status.dart';
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
  Future<List<MovieBaseDto>> getMovies({
    MoviesOrderDto order = MoviesOrderDto.byPopularity,
    bool? isOngoing,
    String? query,
    int? limit,
    int? offset,
    List<WatchStatusDto> watchStatuses = const [],
  }) async {
    final ResponseData<Json> response = await _network.request<Json>(
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
    final ResponseData<Json> shikimoriResponse = await _network.request(
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
        return MovieBaseDto(
          id: movieJson['id']! as int,
          title: (movieJson['titles'] as Json?)?['ru'] as String? ??
              movieJson['title']! as String,
          poster: ImageDto(
            url: {
              60: shikimoriPoster['miniAltUrl']! as String,
              120: shikimoriPoster['miniAlt2xUrl']! as String,
              160: shikimoriPoster['previewAltUrl']! as String,
              225: shikimoriPoster['mainAltUrl']! as String,
              320: shikimoriPoster['previewAlt2xUrl']! as String,
              450: shikimoriPoster['mainAlt2xUrl']! as String,
              double.infinity: shikimoriPoster['originalUrl']! as String,
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
  Future<List<UpNextDto>> getUpNext({required int page}) async {
    if (page != 1 && _upNextMaxPage != null && page > _upNextMaxPage!) {
      return const [];
    }

    final ResponseData<String> response = await _network.request(
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
        late final MovieTypeDto type;
        if (tvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.tv;
        } else if (movieEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.movie;
        } else if (ovaEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.ova;
        } else if (onaEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.ona;
        } else if (specialEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.special;
        } else if (tvSpecialEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.tvSpecial;
        } else if (musicEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.music;
        } else if (pvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          type = MovieTypeDto.preview;
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

        return UpNextDto(
          movie: MovieBaseDto(
            id: movieId,
            title: movieTitle,
            poster: ImageDto(
              url: {
                140: posterUrl,
                double.infinity: posterUrl.replaceFirst('140x140.1.', ''),
              },
            ),
            type: type,
          ),
          episode: EpisodeDto(
            id: episodeId,
            type: type,
            number: episodeNumber,
          ),
        );
      },
    ).toList(growable: false);
  }

  @override
  Future<MovieDetailsDto> getMovie(int id) async {
    final ResponseData<Json> anime365Response = await _network.request(
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

    final ResponseData<Json> shikimoriResponse = await _network.request(
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
    final List<EpisodeDto> previewsAndEpisodes =
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
                  return EpisodeDto(
                    id: episodeJson['id']! as int,
                    type: _convertJsonToMovieType(
                      episodeJson['episodeType']! as String,
                    ),
                    number: number,
                    preview: previewUrl == null
                        ? null
                        : ImageDto(
                            url: {double.infinity: previewUrl},
                          ),
                  );
                },
              ).toList(growable: false);
    final poster = ImageDto(
      url: {
        60: shikimoriPoster['miniAltUrl']! as String,
        120: shikimoriPoster['miniAlt2xUrl']! as String,
        160: shikimoriPoster['previewAltUrl']! as String,
        225: shikimoriPoster['mainAltUrl']! as String,
        320: shikimoriPoster['previewAlt2xUrl']! as String,
        450: shikimoriPoster['mainAlt2xUrl']! as String,
        double.infinity: shikimoriPoster['originalUrl']! as String,
      },
    );

    return MovieDetailsDto(
      id: id,
      url: movieUri.path,
      title: (anime365Data['titles']! as Json)['ru']! as String,
      genres: genres,
      poster: poster,
      previews: previewsAndEpisodes
          .where((episode) => episode.type == MovieTypeDto.preview)
          .toList(growable: false),
      episodes: previewsAndEpisodes
          .where((episode) => episode.type != MovieTypeDto.preview)
          .toList(growable: false),
      episodesCount: anime365Data['numberOfEpisodes']! as int,
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
  Future<List<VideoTranslationDto>> getTranslations(Object episodeId) async {
    final ResponseData<Json> response = await _network.request(
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
          (translationJson) => VideoTranslationDto(
            id: translationJson['id']! as int,
            title: translationJson['authorsSummary']! as String,
            type: translationJson['typeKind']! as String,
            language: translationJson['typeLang']! as String,
            qualityType: translationJson['qualityType']! as String,
            authors: List.from(
              translationJson['authorsList']! as List<dynamic>,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<VideoDto> getTranslationVideo(Object translationId) async {
    final ResponseData<Json> response = await _network.request(
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
    return VideoDto(
      download: {
        for (final Json sourceJson in downloadSourcesJsons)
          sourceJson['height']! as num: sourceJson['url']! as String,
      },
      stream: {
        for (final Json sourceJson in streamSourcesJsons)
          sourceJson['height']! as num:
              (sourceJson['urls']! as List<dynamic>).first as String,
      },
      subtitlesUrl: data['subtitlesUrl'] as String?,
    );
  }

  @override
  Future<void> saveTranslationWatched(Object translationId) {
    return _network.request<void>(
      RequestData(
        uri: Uri(path: '/translations/watched/$translationId'),
        method: RequestMethod.post,
        body: {'csrf': _cookieManager.csrf},
      ),
    );
  }

  @override
  Future<WatchListElementDto> getWatchStatusDetails(Uri movieUri) async {
    final ResponseData<String> response = await _network.request(
      RequestData(
        uri: Uri(path: '$movieUri'),
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
    final int? watchedEpisodesCount = watchedEpisodesCountValue == null
        ? null
        : int.parse(watchedEpisodesCountValue);

    final String? episodesCountValue = animeListForm
        .querySelector(
          'input#UsersRates_episodes',
        )
        ?.attributes['max'];
    final int? episodesCount =
        episodesCountValue == null ? null : int.parse(episodesCountValue);

    return status == null
        ? const WatchListElementDto(status: WatchStatusDto.none)
        : WatchListElementDto(
            status: switch (status) {
              'Запланировано' => WatchStatusDto.planned,
              'Смотрю' => WatchStatusDto.watching,
              'Просмотрено' => WatchStatusDto.completed,
              'Отложено' => WatchStatusDto.onHold,
              'Брошено' => WatchStatusDto.dropped,
              final Object? unsupported => throw UnsupportedError(
                  'Unsupported movie status: $unsupported',
                ),
            },
            score: score,
            watchedEpisodesCount: watchedEpisodesCount,
            episodesCount: episodesCount,
          );
  }

  MovieTypeDto _convertJsonToMovieType(String json) {
    return switch (json) {
      'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieTypeDto.tv,
      'movie' => MovieTypeDto.movie,
      'ova' => MovieTypeDto.ova,
      'ona' => MovieTypeDto.ona,
      'special' => MovieTypeDto.special,
      'tv_special' => MovieTypeDto.tvSpecial,
      'cm' => MovieTypeDto.ad,
      'music' => MovieTypeDto.music,
      'preview' || 'pv' => MovieTypeDto.preview,
      final Object? unsupported => throw UnsupportedError(
          'Unsupported movie type: $unsupported',
        ),
    };
  }

  String _convertMoviesOrderToJson(MoviesOrderDto order) {
    return switch (order) {
      MoviesOrderDto.byScore => 'ranked',
      MoviesOrderDto.byPopularity => 'popularity',
      MoviesOrderDto.byName => 'name',
      MoviesOrderDto.byReleaseDate => 'aired_on',
      MoviesOrderDto.random => 'random',
    };
  }

  int _convertWatchStatusToJson(WatchStatusDto watchStatus) {
    return switch (watchStatus) {
      WatchStatusDto.planned => 0,
      WatchStatusDto.watching => 1,
      WatchStatusDto.completed => 2,
      WatchStatusDto.onHold => 3,
      WatchStatusDto.dropped => 4,
      WatchStatusDto.none => -1,
    };
  }
}
