import 'package:app/core/core.dart';
import 'package:app/features/l10n/l10n.dart';
import 'package:app/features/movies/domain/models/movie_base.dart';
import 'package:app/features/movies/domain/models/up_next.dart';
import 'package:flutter/foundation.dart';

class MovieCardData {
  const MovieCardData({
    required this.poster,
    required this.title,
    required this.subtitle,
    this.score,
    required this.onPressed,
    this.onLongPressed,
  });

  factory MovieCardData.fromUpNext(
    UpNextData upNext, {
    required L10n l10n,
    required VoidCallback onPressed,
    VoidCallback? onLongPressed,
  }) =>
      MovieCardData(
        poster: upNext.movie.poster,
        title: upNext.movie.title,
        subtitle: upNext.episode.number == null
            ? l10n.movieType(upNext.episode.type.name)
            : l10n.movieEpisode(
                upNext.episode.type.name,
                upNext.episode.number!,
              ),
        onPressed: onPressed,
        onLongPressed: onLongPressed,
      );

  factory MovieCardData.fromMovie(
    MovieBaseData movie, {
    required L10n l10n,
    required VoidCallback onPressed,
    VoidCallback? onLongPressed,
  }) =>
      MovieCardData(
        poster: movie.poster,
        title: movie.title,
        subtitle: l10n.movieType(movie.type.name),
        score: movie.score,
        onPressed: onPressed,
        onLongPressed: onLongPressed,
      );

  final ImageData poster;

  final String title;

  final String subtitle;

  final double? score;

  final VoidCallback onPressed;

  final VoidCallback? onLongPressed;
}
