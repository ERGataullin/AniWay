import 'package:app/core/core.dart';
import 'package:app/movies/data/converters/anime365/watch_status.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';

abstract class WatchStatusDetailsConverterAnime365 {
  static WatchStatusDetails fromHtml(Element element) {
    final String? status =
        element
            .querySelector(
              'select#UsersRates_status > option[selected="selected"]',
            )
            ?.text;

    final String? scoreValue =
        element
            .querySelector(
              'select#UsersRates_score > option[selected="selected"]',
            )
            ?.attributes['value'];
    final int? score = scoreValue == null ? null : int.parse(scoreValue);

    final String? episodesCountValue =
        element.querySelector('input#UsersRates_episodes')?.attributes['value'];
    final int episodesCount =
        episodesCountValue == null ? 0 : int.parse(episodesCountValue);

    final String? comment =
        element.querySelector('textarea#UsersRates_comment')?.innerHtml;

    return WatchStatusDetails(
      switch (status) {
        'Запланировано' => WatchStatus.planned,
        'Смотрю' => WatchStatus.watching,
        'Просмотрено' => WatchStatus.completed,
        'Отложено' => WatchStatus.onHold,
        'Брошено' => WatchStatus.dropped,
        null => null,
        final Object? value =>
          throw UnsupportedError('Unsupported $WatchStatus: $value'),
      },
      score: score,
      episodesCount: episodesCount,
      comment: comment,
    );
  }

  static Json toFormData(WatchStatusDetails status) {
    return {
      'UsersRates[status]': WatchStatusConverterAnime365.toJson(status.status),
      'UsersRates[score]': status.score,
      'UsersRates[episodes]': status.episodesCount,
      'UsersRates[comment]': status.comment,
    };
  }
}
