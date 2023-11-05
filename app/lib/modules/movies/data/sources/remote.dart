import 'package:core/core.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '/modules/movies/data/sources/source.dart';

class RemoteMoviesDataSource implements MoviesDataSource {
  const RemoteMoviesDataSource({
    required Network network,
  }) : _network = network;

  final Network _network;

  @override
  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    List<String?> watchStatus = const [],
  }) async {
    final NetworkResponseData response = await _network.request(
      NetworkRequestData(
        uri: Uri.parse(
          '/api/series?order=$order&fields=id,titles,posterUrl,type,myAnimeListScore',
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
        final RegExp tvEpisodeTitlePattern = RegExp(r'^\d+ серия$');
        final RegExp movieEpisodeTitlePattern = RegExp(r'^Фильм$');
        final RegExp ovaEpisodeTitlePattern = RegExp(r'^OVA \d+ серия$');
        final RegExp onaEpisodeTitlePattern = RegExp(r'^ONA \d+ серия$');
        final RegExp specialEpisodeTitlePattern =
            RegExp(r'^SPECIAL \d+ серия$');
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
        }
        final RegExp episodeNumberPattern = RegExp(r'\d+');
        final Iterable<RegExpMatch> episodeNumberMatches =
            episodeNumberPattern.allMatches(episodeTitle);
        assert(episodeNumberMatches.length <= 1);
        final int? episodeNumber = episodeNumberMatches.isEmpty
            ? null
            : int.parse(
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
