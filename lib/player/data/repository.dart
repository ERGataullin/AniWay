import 'package:app/core/core.dart';
import 'package:app/player/player.dart';

class PlayerRepository with Initable {
  const PlayerRepository({required PlayerService playerService})
    : _playerService = playerService;

  final PlayerService _playerService;

  /// Получение персонализированных рангов типов переводов видео.
  Future<Map<VideoTranslationType, int>> getTranslationTypesRates() {
    return _playerService.getTranslationTypesRates();
  }

  /// Сохранение персонализированных рангов типов переводов видео.
  Future<void> saveTranslationTypesRates(Map<VideoTranslationType, int> rates) {
    return _playerService.saveTranslationTypesRates(rates);
  }

  /// Получение персонализированных рангов авторов переводов видео.
  Future<Map<String, int>> getTranslationAuthorsRates() {
    return _playerService.getTranslationAuthorsRates();
  }

  /// Сохранение персонализированных рангов авторов переводов видео.
  Future<void> saveTranslationAuthorsRates(Map<String, int> rates) async {
    await _playerService.saveTranslationAuthorsRates(
      rates.map((author, rate) => MapEntry(author.trim().toLowerCase(), rate)),
    );
  }
}
