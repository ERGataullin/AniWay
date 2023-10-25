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
            'Cookie':
                'fv=1693082319; guestId=68965f9bfdc38b3c79e7948a55ffbbed3c9cdd5c1328ef382ed98dc7ead4ce8e; csrf=QTVtRWszdEk4MXBFUGdfTFEyfnZpTkNpT2RHTmhBeE4BdX9OGfRCMkePQcKsWddxT7iZR24lHQlTYk5zQG3NDQ%3D%3D; _ym_uid=1693082308743597111; _ym_d=1693082308; ads-blocked=0; _ym_isad=1; _ym_hostIndex=0-4%2C1-0; hasOneSignalUserId=1; PHPSESSID=acn6urcc2m2vv6drvdndl7gj89; aaaa8ed0da05b797653c4bd51877d861=154604a8cbd1e82745cf96767142f3430858c28aa%3A4%3A%7Bi%3A0%3Bi%3A210324%3Bi%3A1%3Bs%3A5%3A%22Edgar%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222022-03-26+13%3A16%3A05%22%3B%7D%7D',
          },
        ),
      );
}
