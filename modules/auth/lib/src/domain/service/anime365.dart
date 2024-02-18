import 'dart:async';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

_Cookies _cookiesFromCookieValue(String cookieValue) {
  final List<Cookie> cookiesList = cookieValue
      .split(RegExp('; ?'))
      .map(Cookie.fromSetCookieValue)
      .toList(growable: false);

  return {
    for (final Cookie cookie in cookiesList) cookie.name: cookie,
  };
}

typedef _Cookies = Map<String, Cookie>;

typedef _OnCookiesChanged = void Function(_Cookies cookies);

class Anime365AuthService implements AuthService {
  Anime365AuthService({
    required Network network,
    required AuthRepository repository,
  })  : _network = network,
        _repository = repository;

  @override
  final ValueNotifier<bool> signedIn = ValueNotifier(false);

  final Network _network;

  final AuthRepository _repository;

  late final _AuthInterceptor _authInterceptor = _AuthInterceptor(
    onCookiesChanged: _onCookiesChanged,
  );

  @override
  Future<void> initialize() async {
    final String? cookiesString = await _repository.getCookies();
    final Map<String, Cookie> cookies = cookiesString == null
        ? const {}
        : _cookiesFromCookieValue(cookiesString);
    _authInterceptor._cookies = cookies;
    _network.addInterceptor(_authInterceptor);
    signedIn.value = cookies.isNotEmpty;
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
          'csrf':
              _authInterceptor._cookies['csrf']?.value.replaceAll('%3D', '='),
          'LoginForm[username]': email,
          'LoginForm[password]': password,
        },
      ),
    );

    signedIn.value = true;
  }

  @override
  Future<void> signUp() {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    _network.removeInterceptor(_authInterceptor);
    signedIn.dispose();
  }

  Future<void> _onCookiesChanged(_Cookies value) async {
    final String valueString = value.values
        .map((cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');
    await _repository.saveCookies(valueString);
  }
}

class _AuthInterceptor extends NetworkRequestInterceptor {
  _AuthInterceptor({
    _Cookies cookies = const {},
    _OnCookiesChanged? onCookiesChanged,
  })  : _cookies = cookies,
        _onCookiesChanged = onCookiesChanged;

  final _OnCookiesChanged? _onCookiesChanged;

  _Cookies _cookies;

  @override
  FutureOr<NetworkRequestData> onRequest(NetworkRequestData data) async {
    return data.copyWith(
      headers: {
        ...data.headers,
        'cookie': {
          if (data.headers['cookie'] != null)
            ..._cookiesFromCookieValue(data.headers['cookie']!),
          ..._cookies,
        }.values.map((cookie) => '${cookie.name}=${cookie.value}').join('; '),
      },
    );
  }

  @override
  FutureOr<NetworkResponseData> onResponse(NetworkResponseData data) {
    final List<Cookie> setCookies = data.headers['set-cookie']
            ?.map(Cookie.fromSetCookieValue)
            .toList(growable: false) ??
        const [];

    if (setCookies.isEmpty) {
      return data;
    }

    _cookies = {
      ..._cookies,
      for (final Cookie cookie in setCookies) cookie.name: cookie,
    };
    _onCookiesChanged?.call(_cookies);

    return data;
  }
}
