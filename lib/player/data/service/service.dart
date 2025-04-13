import 'package:app/player/domain/models/video_translation_type.dart';

abstract class PlayerService {
  Future<Map<VideoTranslationType, int>> getTranslationTypesRates();

  Future<void> saveTranslationTypesRates(Map<VideoTranslationType, int> rates);

  Future<Map<String, int>> getTranslationAuthorsRates();

  Future<void> saveTranslationAuthorsRates(Map<String, int> rates);
}
