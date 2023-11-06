abstract interface class AuthDataSource {
  const AuthDataSource();

  Future<String?> getAuthToken();

  Future<void> saveAuthToken(String? authToken);
}
