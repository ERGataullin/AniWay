import 'package:core/core.dart';
import 'package:movies/movies.dart';

class Anime365MoviesDataSource implements MoviesDataSource {
  const Anime365MoviesDataSource({
    required Network network,
  }) : _network = network;

  final Network _network;

  @override
  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    int? limit,
    int? offset,
    List<String?> watchStatus = const [],
  }) async {
    final NetworkResponseData response = await _network.request(
      NetworkRequestData(
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
        method: NetworkRequestMethodData.get,
      ),
    );

    return response.body['data'].cast<Map<String, dynamic>>()
        as List<Map<String, dynamic>>;
  }

  @override
  Future<List<Map<String, dynamic>>> getUpNext() async {
    final NetworkResponseData response = await _network.request(
      NetworkRequestData(
        uri: Uri.parse('/?dynpage=1'),
        method: NetworkRequestMethodData.get,
      ),
    );
    final Document document = parse(response.body as String);
    final Element upNextItemsContainer = document.querySelector(
      'content > div.body-container > ' // content body
      'div.container.section > div#m-index-personal-episodes > ' // up next
      // ignore: lines_longer_than_80_chars
      'div.m-new-episodes.m-missed-episodes.card.collection.with-header.z-depth-1 > ' // items card
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
        posterUrl = posterUrl.substring(0, posterUrl.indexOf(posterUrlPostfix));

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
        final RegExp movieEpisodeTitlePattern = RegExp(r'^Фильм$');
        final RegExp ovaEpisodeTitlePattern = RegExp(
          '^OVA ${episodeNumberPattern.pattern} серия\$',
        );
        final RegExp onaEpisodeTitlePattern = RegExp(
          '^ONA ${episodeNumberPattern.pattern} серия\$',
        );
        final RegExp specialEpisodeTitlePattern = RegExp(
          '^SPECIAL ${episodeNumberPattern.pattern} серия\$',
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
        } else if (musicEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'music';
        } else if (pvEpisodeTitlePattern.hasMatch(episodeTitle)) {
          episodeType = 'pv';
        }
        final Iterable<RegExpMatch> episodeNumberMatches =
            episodeNumberPattern.allMatches(episodeTitle);
        assert(episodeNumberMatches.length <= 1);
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
}
