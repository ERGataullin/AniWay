import 'package:core/core.dart';
import 'package:player/player.dart';

class PlayerRepository implements Initable {
  const PlayerRepository({
    required PlayerDataSource local,
  }) : _local = local;

  final PlayerDataSource _local;

  @override
  void init() {}

  @override
  void dispose() {}

  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() {
    return _local.getPersonalizedTranslationAuthorsRates();
  }

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _local.savePersonalizedTranslationAuthorsRates(
      rates.map(
        (author, rate) => MapEntry(
          author.trim().toLowerCase(),
          rate,
        ),
      ),
    );
  }
}
