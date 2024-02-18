abstract interface class AuthDataSource {
  const AuthDataSource();

  Future<String?> getCookies();

  Future<void> saveCookies(String? value);
}
