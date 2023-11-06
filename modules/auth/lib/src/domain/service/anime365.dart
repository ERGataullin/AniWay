import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';

class Anime365AuthService implements AuthService {
  Anime365AuthService({
    required Network network,
    required AuthRepository repository,
  })  : _network = network,
        _repository = repository,
        _authTokenInterceptor = _AuthTokenInterceptor(
          authToken: repository.getAuthToken(),
        ) {
    _network.addInterceptor(_authTokenInterceptor);
  }

  final Network _network;
  final AuthRepository _repository;
  final _AuthTokenInterceptor _authTokenInterceptor;

  @override
  Future<void> signIn(String cookie) {
    _authTokenInterceptor._authToken = Future.value(cookie);
    return _repository.saveAuthToken(cookie);
  }

  @override
  Future<void> signUp() {
    throw UnimplementedError();
  }
}

class _AuthTokenInterceptor extends NetworkRequestInterceptor {
  _AuthTokenInterceptor({
    required Future<String?> authToken,
  }) : _authToken = authToken;

  Future<String?> _authToken;

  set authToken(FutureOr<String?> authToken) =>
      _authToken = Future.value(authToken);

  @override
  FutureOr<NetworkRequestData> onRequest(NetworkRequestData data) =>
      _authToken.then(
        (authToken) => data.copyWith(
          headers: {
            ...data.headers,
            if (authToken != null) 'Cookie': authToken,
          },
        ),
      );
}
