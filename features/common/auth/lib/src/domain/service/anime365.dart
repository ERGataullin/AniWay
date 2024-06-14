import 'dart:async';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:cookie_manager/cookie_manager.dart';
import 'package:core/core.dart';

class Anime365AuthService implements AuthService {
  Anime365AuthService({
    required CookieManager cookieManager,
    required Network network,
  })  : _cookieManager = cookieManager,
        _network = network;

  @override
  late final ComputationNotifier<bool> signedIn = ComputationNotifier(
    trigger: _cookieManager.cookie,
    computation: () {
      final Cookie? session = _cookieManager.cookie.value['PHPSESSID'];
      return session != null &&
          (session.expires == null || session.expires!.isAfter(DateTime.now()));
    },
  );

  final CookieManager _cookieManager;

  final Network _network;

  @override
  Future<void> init() async {
    await _cookieManager.init();
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _network.request(
      NetworkRequestData(
        uri: Uri(path: '/users/login'),
        method: NetworkRequestMethodData.get,
      ),
    );

    await _network.request(
      NetworkRequestData(
        uri: Uri(path: '/users/login'),
        method: NetworkRequestMethodData.post,
        headers: const {
          'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: {
          'csrf': _cookieManager.cookie.value['csrf']?.value,
          'LoginForm[username]': email,
          'LoginForm[password]': password,
        },
      ),
    );
  }

  @override
  Future<void> signUp() {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    signedIn.dispose();
  }
}
