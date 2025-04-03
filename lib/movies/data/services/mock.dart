import 'dart:ui';

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

class MoviesServiceMock implements MoviesService {
  const MoviesServiceMock();

  @override
  Future<List<MovieBaseData>> getMovies({
    MoviesOrder order = MoviesOrder.byPopularity,
    bool? isOngoing,
    String? query,
    int? limit,
    int? offset,
    List<MovieType> typesExcluded = const [],
    List<WatchStatus> watchStatuses = const [],
  }) async {
    assert(typesExcluded.isEmpty || query == null);
    await _delay();
    return [
      MovieBaseData(
        id: 52991,
        title: 'Провожающая в последний путь Фрирен',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/52991/dc841cc9fce2aa1e9907a4b61c5d1d92.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 5114,
        title: 'Стальной алхимик: Братство',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/5114/40c4cba552dc60ebf02f8fc373b9a503.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 9253,
        title: 'Врата Штейна',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/9253/475db7c6df0f11d567138322aebf411b.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 38524,
        title: 'Атака титанов 3. Часть 2',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/38524/6e47d9541f0a77b994c1f487408121e6.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 60022,
        title: 'Ван-Пис: Письмо от поклонника',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/60022/dcf90d09dcf677650f0335eb37cc3b78.jpeg',
            ),
          },
        ),
        type: MovieType.tvSpecial,
      ),
      MovieBaseData(
        id: 28977,
        title: 'Гинтама 4',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/28977/22e8b06a4dbbacb7b6ae409412389464.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 39486,
        title: 'Гинтама: Финал',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/39486/bca218aa90d109c4002b8f6429c61c4c.jpeg',
            ),
          },
        ),
        type: MovieType.movie,
      ),
      MovieBaseData(
        id: 9969,
        title: 'Гинтама 2',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/9969/66c315230c81f14202f76ba049a0f79a.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 11061,
        title: 'Охотник х Охотник (2011)',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/11061/09a4196c062532ec7a6a0a74ca201fda.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
      MovieBaseData(
        id: 15417,
        title: 'Гинтама 3',
        poster: ImageData(
          resolutionsUris: {
            double.infinity: Uri.parse(
              'https://shikimori.one/uploads/poster/animes/15417/42af66eae166e9537d07590967d5f565.jpeg',
            ),
          },
        ),
        type: MovieType.tv,
      ),
    ];
  }

  @override
  Future<List<UpNextData>> getUpNext({required int page}) async {
    if (page != 1 && page > 5) {
      return const [];
    }

    await _delay();

    return [
      UpNextData(
        movie: MovieBaseData(
          id: 52991,
          title: 'Провожающая в последний путь Фрирен',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/52991/dc841cc9fce2aa1e9907a4b61c5d1d92.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 2),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 5114,
          title: 'Стальной алхимик: Братство',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/5114/40c4cba552dc60ebf02f8fc373b9a503.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 2),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 9253,
          title: 'Врата Штейна',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/9253/475db7c6df0f11d567138322aebf411b.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 3),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 38524,
          title: 'Атака титанов 3. Часть 2',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/38524/6e47d9541f0a77b994c1f487408121e6.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 4),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 60022,
          title: 'Ван-Пис: Письмо от поклонника',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/60022/dcf90d09dcf677650f0335eb37cc3b78.jpeg',
              ),
            },
          ),
          type: MovieType.tvSpecial,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tvSpecial, number: 1),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 28977,
          title: 'Гинтама 4',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/28977/22e8b06a4dbbacb7b6ae409412389464.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 6),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 39486,
          title: 'Гинтама: Финал',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/39486/bca218aa90d109c4002b8f6429c61c4c.jpeg',
              ),
            },
          ),
          type: MovieType.movie,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.movie, number: 1),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 9969,
          title: 'Гинтама 2',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/9969/66c315230c81f14202f76ba049a0f79a.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 8),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 11061,
          title: 'Охотник х Охотник (2011)',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/11061/09a4196c062532ec7a6a0a74ca201fda.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 9),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 15417,
          title: 'Гинтама 3',
          poster: ImageData(
            resolutionsUris: {
              double.infinity: Uri.parse(
                'https://shikimori.one/uploads/poster/animes/15417/42af66eae166e9537d07590967d5f565.jpeg',
              ),
            },
          ),
          type: MovieType.tv,
        ),
        episode: const EpisodeData(id: 1, type: MovieType.tv, number: 10),
      ),
    ];
  }

  @override
  Future<MovieDetailsData> getMovie(int id) async {
    await _delay();
    return MovieDetailsData(
      id: id,
      uri: Uri.parse('https://shikimori.one/animes/$id'),
      title: 'Сага о Винланде 2',
      genres: ['Сэйнэн', 'Экшен', 'Приключения', 'Драма'],
      poster: ImageData(
        resolutionsUris: {
          double.infinity: Uri.parse(
            'https://shikimori.one/uploads/poster/animes/49387/1770e442cbce434da85f7c9a0cb9b33e.jpeg',
          ),
        },
      ),
      previews: const [],
      episodes: List.generate(
        10,
        (index) => EpisodeData(id: id, type: MovieType.tv, number: index + 1),
      ),
    );
  }

  @override
  Future<List<VideoTranslationData>> getTranslations(Object episodeId) async {
    await _delay();
    return List.generate(
      10,
      (index) => VideoTranslationData(
        id: index,
        title: 'Озвучка №$index',
        type: VideoTranslationType.voice,
        locale: const Locale('ru', 'RU'),
        qualityType: VideoQualityType.bd,
      ),
    );
  }

  @override
  Future<VideoData> getTranslationVideo(Object translationId) async {
    await _delay();
    return VideoData(
      download: {
        360: Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
        720: Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
      },
      stream: {
        360: Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
        720: Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
      },
    );
  }

  @override
  Future<void> saveTranslationWatched(Object translationId) async {
    await _delay();
  }

  @override
  Future<WatchListElementData> getWatchStatusDetails(Uri movieUri) async {
    await _delay();
    return const WatchListElementData(
      status: WatchStatus.watching,
      score: 8,
      watchedEpisodesCount: 3,
      episodesCount: 10,
    );
  }

  Future<void> _delay() {
    return Future.delayed(const Duration(seconds: 1));
  }
}
