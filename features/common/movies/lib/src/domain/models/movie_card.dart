import 'package:flutter/foundation.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/up_next.dart';

class MovieCardData {
  const MovieCardData({
    required this.posterUri,
    required this.title,
    required this.subtitle,
    this.score,
    required this.onPressed,
  });

  factory MovieCardData.fromUpNext(
    UpNextData upNext, {
    required L10n l10n,
    required VoidCallback onPressed,
  }) =>
      MovieCardData(
        posterUri: upNext.movie.posterUri,
        title: upNext.movie.title,
        subtitle: upNext.episode.number == null
            ? l10n.movieType(upNext.episode.type.name)
            : l10n.movieEpisode(
                upNext.episode.type.name,
                upNext.episode.number!,
              ),
        onPressed: onPressed,
      );

  factory MovieCardData.fromMovie(
    MovieBaseData movie, {
    required L10n l10n,
    required VoidCallback onPressed,
  }) =>
      MovieCardData(
        posterUri: movie.posterUri,
        title: movie.title,
        subtitle: l10n.movieType(movie.type.name),
        score: movie.score,
        onPressed: onPressed,
      );

  final Uri posterUri;

  final String title;

  final String subtitle;

  final double? score;

  final VoidCallback onPressed;
}
