import '/modules/movies/data/sources/source.dart';

class RemoteMoviesDataSource implements MoviesDataSource {
  const RemoteMoviesDataSource();

  @override
  Future<List<Map<String, dynamic>>> getMovies() {
    return Future.value(const [
      {
        'id': 2400,
        'titles': {
          'ru': 'Стальной алхимик: Братство',
        },
        'posterUrl': 'https://smotretanime.ru/posters/2400.10127424714.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.1,
      },
      {
        'id': 914,
        'titles': {
          'ru': 'Врата Штейна',
        },
        'posterUrl': 'https://smotretanime.ru/posters/914.11477207554.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.07,
      },
      {
        'id': 9815,
        'titles': {
          'ru': 'Гинтама 4 сезон',
        },
        'posterUrl': 'https://smotretanime.ru/posters/9815.35700322134.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.06,
      },
      {
        'id': 2400,
        'titles': {
          'ru': 'Стальной алхимик: Братство',
        },
        'posterUrl': 'https://smotretanime.ru/posters/2400.10127424714.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.1,
      },
      {
        'id': 914,
        'titles': {
          'ru': 'Врата Штейна',
        },
        'posterUrl': 'https://smotretanime.ru/posters/914.11477207554.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.07,
      },
      {
        'id': 9815,
        'titles': {
          'ru': 'Гинтама 4 сезон',
        },
        'posterUrl': 'https://smotretanime.ru/posters/9815.35700322134.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.06,
      },
      {
        'id': 2400,
        'titles': {
          'ru': 'Стальной алхимик: Братство',
        },
        'posterUrl': 'https://smotretanime.ru/posters/2400.10127424714.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.1,
      },
      {
        'id': 914,
        'titles': {
          'ru': 'Врата Штейна',
        },
        'posterUrl': 'https://smotretanime.ru/posters/914.11477207554.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.07,
      },
      {
        'id': 9815,
        'titles': {
          'ru': 'Гинтама 4 сезон',
        },
        'posterUrl': 'https://smotretanime.ru/posters/9815.35700322134.jpg',
        'type': 'tv',
        'myAnimeListScore': 9.06,
      },
    ]);
  }
}
