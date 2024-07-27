import 'package:core/core.dart';
import 'package:player/player.dart';

class LocalPlayerDataSource implements PlayerDataSource {
  const LocalPlayerDataSource({
    required Storage storage,
  }) : _storage = storage;

  static const String _collection = 'player';

  static const String _personalizedTranslationAuthorsRatesKey =
      'personalized_translation_authors_rates';

  final Storage _storage;

  @override
  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() async {
    final Map<Object?, Object?>? stored = await _storage.get(
      collection: _collection,
      key: _personalizedTranslationAuthorsRatesKey,
    );
    return Map.from(stored ?? const {});
  }

  @override
  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _storage.put(
      collection: _collection,
      key: _personalizedTranslationAuthorsRatesKey,
      value: rates,
    );
  }
}
