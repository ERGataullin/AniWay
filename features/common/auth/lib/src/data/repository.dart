import 'dart:async';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';

class AuthRepository implements Initable {
  AuthRepository({
    required AuthDataSource remote,
    required CookieManager cookieManager,
  })  : _remote = remote,
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

  final AuthDataSource _remote;

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
    return _remote.signIn(
      email: email,
      password: password,
    );
  }
}
