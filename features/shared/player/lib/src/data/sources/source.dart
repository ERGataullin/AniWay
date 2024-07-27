abstract class PlayerDataSource {
  Future<Map<String, int>> getPersonalizedTranslationAuthorsRates();

  Future<void> savePersonalizedTranslationAuthorsRates(
    Map<String, int> rates,
  );
}
