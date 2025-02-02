import 'dart:async';
import 'dart:io';

import 'package:app/core/core.dart';
import 'package:app/features/auth/auth.dart';
import 'package:app/features/cookie_manager/cookie_manager.dart';

class AuthRepository implements Initable {
  AuthRepository({
    required AuthService authService,
    required CookieManager cookieManager,
  })  : _authService = authService,
        _cookieManager = cookieManager;

  late final Computed<bool> signedIn = Computed(
    trigger: _cookieManager.cookie,
    () {
      final Cookie? session = _cookieManager.cookie.value['PHPSESSID'];
      return session != null &&
          _cookieManager.cookie.value['aaaa8ed0da05b797653c4bd51877d861'] !=
              null &&
          (session.expires == null || session.expires!.isAfter(DateTime.now()));
    },
  );

  final AuthService _authService;

  final CookieManager _cookieManager;

  @override
  void init() {}

  @override
  void dispose() {
    signedIn.dispose();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(
      email: email,
      password: password,
    );
  }
}
