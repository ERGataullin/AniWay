import 'package:core/core.dart';
import 'package:player/player.dart';

class PlayerService implements Initable {
  const PlayerService({
    required PlayerRepository repository,
  }) : _repository = repository;

  final PlayerRepository _repository;

  @override
  void init() {}

  @override
  void dispose() {}

  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() {
    return _repository.getPersonalizedTranslationAuthorsRates();
  }

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _repository.savePersonalizedTranslationAuthorsRates(
      rates.map(
        (author, rate) => MapEntry(
          author.trim().toLowerCase(),
          rate,
        ),
      ),
    );
  }
}
