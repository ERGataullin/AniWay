import 'dart:async';

import 'package:app/auth/auth.dart';
import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';

class AuthServiceAnime365 implements AuthService {
  AuthServiceAnime365({
    required NetworkService networkService,
    required CookieManager cookieManager,
  }) : _networkService = networkService,
       _cookieManager = cookieManager;

  final NetworkService _networkService;

  final CookieManager _cookieManager;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _networkService.request<void>(
      RequestData(method: RequestMethod.get, uri: Uri(path: '/users/login')),
    );

    await _networkService.request<void>(
      RequestData(
        method: RequestMethod.post,
        uri: Uri(path: '/users/login'),
        headers: const {
          'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: {
          'csrf': _cookieManager.cookie.value['csrf']?.valueDecoded,
          'LoginForm[username]': email,
          'LoginForm[password]': password,
        },
      ),
    );
  }
}
