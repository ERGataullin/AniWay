import 'package:app/movies/data/services/service.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/player/player.dart';

class MoviesServiceMock implements MoviesService {
  const MoviesServiceMock();

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
    await _delay();
    return [
      .new(
        id: 52991,
        title: 'Провожающая в последний путь Фрирен',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/52991/dc841cc9fce2aa1e9907a4b61c5d1d92.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 5114,
        title: 'Стальной алхимик: Братство',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/5114/40c4cba552dc60ebf02f8fc373b9a503.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 9253,
        title: 'Врата Штейна',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/9253/475db7c6df0f11d567138322aebf411b.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 38524,
        title: 'Атака титанов 3. Часть 2',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/38524/6e47d9541f0a77b994c1f487408121e6.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 60022,
        title: 'Ван-Пис: Письмо от поклонника',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/60022/dcf90d09dcf677650f0335eb37cc3b78.jpeg',
            ),
          },
        ),
        type: .tvSpecial,
      ),
      .new(
        id: 28977,
        title: 'Гинтама 4',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/28977/22e8b06a4dbbacb7b6ae409412389464.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 39486,
        title: 'Гинтама: Финал',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/39486/bca218aa90d109c4002b8f6429c61c4c.jpeg',
            ),
          },
        ),
        type: .movie,
      ),
      .new(
        id: 9969,
        title: 'Гинтама 2',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/9969/66c315230c81f14202f76ba049a0f79a.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 11061,
        title: 'Охотник х Охотник (2011)',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/11061/09a4196c062532ec7a6a0a74ca201fda.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
      .new(
        id: 15417,
        title: 'Гинтама 3',
        poster: .new(
          resolutionsUris: {
            double.infinity: .parse(
              'https://shikimori.one/uploads/poster/animes/15417/42af66eae166e9537d07590967d5f565.jpeg',
            ),
          },
        ),
        type: .tv,
      ),
    ];
  }

  @override
  Future<List<UpNextData>> getUpNext({required int page}) async {
    if (page != 1 && page > 5) return const [];

    await _delay();

    return [
      .new(
        movie: .new(
          id: 52991,
          title: 'Провожающая в последний путь Фрирен',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/52991/dc841cc9fce2aa1e9907a4b61c5d1d92.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 2),
      ),
      .new(
        movie: .new(
          id: 5114,
          title: 'Стальной алхимик: Братство',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/5114/40c4cba552dc60ebf02f8fc373b9a503.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 2),
      ),
      UpNextData(
        movie: MovieBaseData(
          id: 9253,
          title: 'Врата Штейна',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/9253/475db7c6df0f11d567138322aebf411b.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 3),
      ),
      .new(
        movie: .new(
          id: 38524,
          title: 'Атака титанов 3. Часть 2',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/38524/6e47d9541f0a77b994c1f487408121e6.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 4),
      ),
      .new(
        movie: .new(
          id: 60022,
          title: 'Ван-Пис: Письмо от поклонника',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/60022/dcf90d09dcf677650f0335eb37cc3b78.jpeg',
              ),
            },
          ),
          type: .tvSpecial,
        ),
        episode: const .new(id: 1, type: .tvSpecial, number: 1),
      ),
      .new(
        movie: .new(
          id: 28977,
          title: 'Гинтама 4',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/28977/22e8b06a4dbbacb7b6ae409412389464.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 6),
      ),
      .new(
        movie: .new(
          id: 39486,
          title: 'Гинтама: Финал',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/39486/bca218aa90d109c4002b8f6429c61c4c.jpeg',
              ),
            },
          ),
          type: .movie,
        ),
        episode: const .new(id: 1, type: .movie, number: 1),
      ),
      .new(
        movie: .new(
          id: 9969,
          title: 'Гинтама 2',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/9969/66c315230c81f14202f76ba049a0f79a.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 8),
      ),
      .new(
        movie: .new(
          id: 11061,
          title: 'Охотник х Охотник (2011)',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/11061/09a4196c062532ec7a6a0a74ca201fda.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 9),
      ),
      .new(
        movie: .new(
          id: 15417,
          title: 'Гинтама 3',
          poster: .new(
            resolutionsUris: {
              double.infinity: .parse(
                'https://shikimori.one/uploads/poster/animes/15417/42af66eae166e9537d07590967d5f565.jpeg',
              ),
            },
          ),
          type: .tv,
        ),
        episode: const .new(id: 1, type: .tv, number: 10),
      ),
    ];
  }

  @override
  Future<MovieDetailsData> getMovie(int id) async {
    await _delay();
    return .new(
      id: id,
      uri: .parse('https://shikimori.one/animes/$id'),
      title: 'Сага о Винланде 2',
      genres: ['Сэйнэн', 'Экшен', 'Приключения', 'Драма'],
      poster: .new(
        resolutionsUris: {
          double.infinity: .parse(
            'https://shikimori.one/uploads/poster/animes/49387/1770e442cbce434da85f7c9a0cb9b33e.jpeg',
          ),
        },
      ),
      previews: const [],
      episodesCount: 10,
      episodes: .generate(
        10,
        (index) => .new(id: id, type: .tv, number: index + 1),
      ),
    );
  }

  @override
  Future<List<TranslationData>> getTranslations(Object episodeId) async {
    await _delay();
    return .generate(
      10,
      (index) => .new(
        id: index,
        uri: .parse('https://smotret-anime.org/catalog/anime-19730'),
        title: 'Озвучка №$index',
        type: .voice,
        locale: const .new('ru', 'RU'),
        qualityType: .bd,
      ),
    );
  }

  @override
  Future<VideoData> getTranslationVideo(int translationId) async {
    await _delay();
    return .new(
      download: {
        360: .parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
        720: .parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
      },
      stream: {
        360: .parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
        720: .parse(
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
  Future<WatchStatusDetails> getWatchStatus(Uri movieUri) async {
    await _delay();
    return const .new(.watching, score: 8, episodesCount: 3);
  }

  @override
  Future<WatchStatusDetails> saveWatchStatus({
    required int movieId,
    required WatchStatusDetails status,
  }) async {
    await _delay();
    return status;
  }

  Future<void> _delay() {
    return .delayed(const .new(seconds: 1));
  }
}
