import 'dart:async';

import 'package:app/auth/auth.dart';
import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';

class AuthRepository with Initable {
  AuthRepository({required this._authService, required this._cookieManager});

  late final Computed<bool> signedIn = .new(trigger: _cookieManager.cookie, () {
    return _cookieManager.cookie.value.containsKey('csrf');
    // TODO(Edgar): Вернуть после поднятия прокси.
    // final Cookie? session = _cookieManager.cookie.value['PHPSESSID'];
    // return session != null &&
    //     _cookieManager.cookie.value['aaaa8ed0da05b797653c4bd51877d861'] !=
    //         null &&
    //     (session.expires == null || session.expires!.isAfter(.now()));
  });

  final AuthService _authService;

  final CookieManager _cookieManager;

  @override
  void dispose() {
    signedIn.dispose();
    super.dispose();
  }

  Future<void> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }
}
