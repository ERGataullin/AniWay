import 'dart:async';
import 'dart:io';

import 'package:app/auth/auth.dart';
import 'package:app/cookie_manager/cookie_manager.dart';
import 'package:app/core/core.dart';

class AuthServiceMock implements AuthService {
  AuthServiceMock({required CookieManager cookieManager})
    : _cookieManager = cookieManager;

  final CookieManager _cookieManager;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _delay();
    _cookieManager.interceptor.handleResponse(
      const ResponseData(
        headers: {
          HttpHeaders.setCookieHeader:
              'PHPSESSID=b5vo320s2da3r5p0nl3341t89c; path=/; secure; HttpOnly',
        },
        body: null,
      ),
    );
    _cookieManager.interceptor.handleResponse(
      const ResponseData(
        headers: {
          HttpHeaders.setCookieHeader:
              'aaaa8ed0da05b797653c4bd51877d861=07b9a6d3ddea7a4309773a9690d8691c4c8665d7a%3A4%3A%7Bi%3A0%3Bi%3A231915%3Bi%3A1%3Bs%3A11%3A%22Marat+Shiga%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222023-11-06+15%3A58%3A16%22%3B%7D%7D; expires=Wed, 30-Apr-2099 18:06:15 GMT; Max-Age=2592000; path=/; secure; HttpOnly; SameSite=None',
        },
        body: null,
      ),
    );
  }

  Future<void> _delay() {
    return Future.delayed(const Duration(seconds: 1));
  }
}
