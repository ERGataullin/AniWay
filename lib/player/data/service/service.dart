import 'package:app/player/domain/models/translation_type.dart';

abstract class PlayerService {
  Future<Map<TranslationType, int>> getTranslationTypesRates();

  Future<void> saveTranslationTypesRates(Map<TranslationType, int> rates);

  Future<Map<String, int>> getTranslationAuthorsRates();

  Future<void> saveTranslationAuthorsRates(Map<String, int> rates);
}
