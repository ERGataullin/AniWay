import 'dart:async';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';

class AuthService implements Initable {
  AuthService({
    required AuthRepository repository,
    required CookieManager cookieManager,
  })  : _repository = repository,
        _cookieManager = cookieManager;

  late final DynamicData<bool> signedIn = DynamicData(
    trigger: _cookieManager.cookie,
    () {
      final Cookie? session = _cookieManager.cookie.value['PHPSESSID'];
      return session != null &&
          _cookieManager.cookie.value['aaaa8ed0da05b797653c4bd51877d861'] !=
              null &&
          (session.expires == null || session.expires!.isAfter(DateTime.now()));
    },
  );

  final AuthRepository _repository;

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
    return _repository.signIn(
      email: email,
      password: password,
    );
  }
}
