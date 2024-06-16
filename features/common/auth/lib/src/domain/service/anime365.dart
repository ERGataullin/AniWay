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
    () {
      final Cookie? session = _cookieManager.cookie.value['PHPSESSID'];
      return session != null &&
          _cookieManager.cookie.value['aaaa8ed0da05b797653c4bd51877d861'] !=
              null &&
          (session.expires == null || session.expires!.isAfter(DateTime.now()));
    },
  );

  final CookieManager _cookieManager;

  final Network _network;

  @override
  void init() {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _network.request(
      RequestData(
        uri: Uri(path: '/users/login'),
        method: RequestMethod.get,
      ),
    );

    await _network.request(
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

  @override
  Future<void> signUp() {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    signedIn.dispose();
  }
}
