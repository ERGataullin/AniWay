import 'package:app/core/core.dart';
import 'package:app/player/player.dart';

class PlayerRepository with Initable {
  const PlayerRepository({required PlayerService playerService})
    : _playerService = playerService;

  final PlayerService _playerService;

  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() {
    return _playerService.getPersonalizedTranslationAuthorsRates();
  }

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _playerService.savePersonalizedTranslationAuthorsRates(
      rates.map((author, rate) => MapEntry(author.trim().toLowerCase(), rate)),
    );
  }
}
