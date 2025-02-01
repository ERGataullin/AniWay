import 'dart:async';

import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';

class Anime365AuthService implements AuthService {
  Anime365AuthService({
    required NetworkService networkService,
    required CookieManager cookieManager,
  })  : _network = networkService,
        _cookieManager = cookieManager;

  final NetworkService _network;

  final CookieManager _cookieManager;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _network.request<void>(
      RequestData(
        uri: Uri(path: '/users/login'),
        method: RequestMethod.get,
      ),
    );

    await _network.request<void>(
      RequestData(
        uri: Uri(path: '/users/login'),
        method: RequestMethod.post,
        headers: const {
          'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: {
          'csrf': _cookieManager.csrf,
          'LoginForm[username]': email,
          'LoginForm[password]': password,
        },
      ),
    );
  }
}
