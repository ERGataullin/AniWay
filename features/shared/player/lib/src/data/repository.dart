import 'package:core/core.dart';
import 'package:player/player.dart';

class PlayerRepository implements Initable {
  const PlayerRepository({
    required PlayerService playerService,
  }) : _playerService = playerService;

  final PlayerService _playerService;

  @override
  void init() {}

  @override
  void dispose() {}

  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() {
    return _playerService.getPersonalizedTranslationAuthorsRates();
  }

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _playerService.savePersonalizedTranslationAuthorsRates(
      rates.map(
        (author, rate) => MapEntry(
          author.trim().toLowerCase(),
          rate,
        ),
      ),
    );
  }
}
