import 'package:player/player.dart';

class PlayerRepository {
  const PlayerRepository({
    required PlayerDataSource local,
  }) : _local = local;

  final PlayerDataSource _local;

  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() {
    return _local.getPersonalizedTranslationAuthorsRates();
  }

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _local.savePersonalizedTranslationAuthorsRates(rates);
  }
}
