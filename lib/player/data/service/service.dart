abstract class PlayerService {
  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates();

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  );
}
