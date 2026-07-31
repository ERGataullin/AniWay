import 'package:app/core/core.dart';
import 'package:app/player/player.dart';

class LocalPlayerService implements PlayerService {
  const LocalPlayerService({required this._storageService});

  static const _collection = 'player';

  static const _translationTypesRatesKey = 'translation_kinds_rates';

  static const _translationAuthorsRatesKey =
      'personalized_translation_authors_rates';

  final StorageService _storageService;

  @override
  Future<Map<TranslationType, int>> getTranslationTypesRates() async {
    final Map<dynamic, dynamic> stored = await _storageService.get(
      collection: _collection,
      key: _translationTypesRatesKey,
      defaultValue: const {},
    );
    return {
      for (final MapEntry<Object?, Object?> entry in stored.entries)
        .valueOf(entry.key! as String): entry.value! as int,
    };
  }

  @override
  Future<void> saveTranslationTypesRates(
    Map<TranslationType, int> rates,
  ) async {
    await _storageService.put<Map<dynamic, dynamic>>(
      collection: _collection,
      key: _translationTypesRatesKey,
      value: rates.map((type, rate) => MapEntry(type.name, rate)),
    );
  }

  @override
  Future<Map<String, int>> getTranslationAuthorsRates() async {
    final Map<dynamic, dynamic> stored = await _storageService.get(
      collection: _collection,
      key: _translationAuthorsRatesKey,
      defaultValue: const {},
    );
    return Map.from(stored);
  }

  @override
  Future<void> saveTranslationAuthorsRates(Map<String, int> rates) async {
    await _storageService.put<Map<dynamic, dynamic>>(
      collection: _collection,
      key: _translationAuthorsRatesKey,
      value: rates,
    );
  }
}
