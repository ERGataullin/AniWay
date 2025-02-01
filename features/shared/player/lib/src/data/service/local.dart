import 'package:core/core.dart';
import 'package:player/player.dart';

class LocalPlayerService implements PlayerService {
  const LocalPlayerService({
    required StorageService storageService,
  }) : _storageService = storageService;

  static const String _collection = 'player';

  static const String _personalizedTranslationAuthorsRatesKey =
      'personalized_translation_authors_rates';

  final StorageService _storageService;

  @override
  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates() async {
    final Map<Object?, Object?> stored = await _storageService.get(
      collection: _collection,
      key: _personalizedTranslationAuthorsRatesKey,
      defaultValue: const {},
    );
    return Map.from(stored);
  }

  @override
  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  ) async {
    await _storageService.put<Map<Object?, Object?>>(
      collection: _collection,
      key: _personalizedTranslationAuthorsRatesKey,
      value: rates,
    );
  }
}
