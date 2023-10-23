import 'dart:async';

import '/app/domain/services/network/service.dart';
import '/modules/auth/data/repository.dart';

class AuthService {
  AuthService({
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
  //
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _networkService
        .request(
          NetworkRequestData(
            uri: Uri.parse('/users/login'),
            method: NetworkRequestMethodData.post,
            headers: {'Content-type': 'html'},
            body: {
              'LoginForm[username]': email,
              'LoginForm[password]': password,
            },
          ),
        ).then((response) => print(response.body));
        // .then((response) => response.body as String);
        // .then((authToken) => _authTokenInterceptor.authToken = authToken)
        // .then((authToken) => unawaited(_repository.saveAuthToken(authToken)));
  }

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
            'Cookie': authToken,
          },
        ),
      );
}
