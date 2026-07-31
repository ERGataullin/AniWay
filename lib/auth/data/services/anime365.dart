import 'dart:async';
import 'dart:io';

import 'package:app/auth/auth.dart';
import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';

class AuthServiceAnime365 implements AuthService {
  AuthServiceAnime365({
    required this._networkService,
    required this._cookieManager,
  });

  final NetworkService _networkService;

  final CookieManager _cookieManager;

  @override
  Future<void> signIn({required String email, required String password}) async {
    // Инициализация аутентификации для получения CSRF токена.
    final ResponseData<String> response = await _networkService.request(
      RequestData(
        method: RequestMethod.get,
        uri: Uri(path: '/users/login'),
      ),
    );
    final Document document = parse(response.body);
    // TODO(Edgar): Удалить после поднятия прокси.
    final String csrf = document
        .querySelector('input[name="csrf"]')!
        .attributes['value']!;
    _cookieManager.cookie.value = {
      ..._cookieManager.cookie.value,
      'csrf': Cookie('csrf', csrf),
    };

    await _networkService.request<void>(
      RequestData(
        method: RequestMethod.post,
        uri: Uri(path: '/users/login'),
        headers: const {'content-type': 'application/x-www-form-urlencoded'},
        body: {
          'csrf': csrf,
          'LoginForm[username]': email,
          'LoginForm[password]': password,
        },
      ),
    );
  }
}
