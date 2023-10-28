import 'dart:async';

import '/app/domain/services/network/service.dart';
import '/modules/auth/data/repository.dart';
import '/modules/auth/domain/service/service.dart';

class Anime365AuthService implements AuthService {
  Anime365AuthService({
    required NetworkService networkService,
    required AuthRepository repository,
  })  : _networkService = networkService,
        _repository = repository,
        _authTokenInterceptor = _AuthTokenInterceptor(
          authToken: repository.getAuthToken(),
        ) {
    _networkService.addInterceptor(_authTokenInterceptor);
  }

  final NetworkService _networkService;
  final AuthRepository _repository;
  final _AuthTokenInterceptor _authTokenInterceptor;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _networkService
        .request(
          NetworkRequestData(
            uri: Uri.parse('/users/login'),
            method: NetworkRequestMethodData.post,
            body: {
              'LoginForm[username]': email,
              'LoginForm[password]': password,
            },
          ),
        )
        .then((response) => response.body as String)
        .then((authToken) => _authTokenInterceptor.authToken = authToken)
        .then((authToken) => unawaited(_repository.saveAuthToken(authToken)));
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
            'Cookie': 'PHPSESSID=d04e881hiqiua73unv6ptvleg1',
          },
        ),
      );
}
