import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

typedef CookieMap = Map<String, Cookie>;

abstract class CookieManager {
  ValueListenable<CookieMap> get cookie;

  NetworkRequestInterceptor get interceptor;

  @mustCallSuper
  Future<void> init();

  @mustCallSuper
  void dispose();
}

class CookieManagerImpl extends NetworkRequestInterceptor
    implements CookieManager {
  CookieManagerImpl({
    required Storage storage,
  }) : _storage = storage;

  static const String _effectiveCookieHeaderName =
      kIsWeb ? 'kaki' : HttpHeaders.cookieHeader;

  static const String _effectiveSetCookieHeaderName =
      kIsWeb ? 'set-kaki' : HttpHeaders.setCookieHeader;

  static final Pattern _setCookieSplitter = RegExp(
    r'[ \t]*,[ \t]*(?=['
    r"!#$%&'*+\-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`"
    'abcdefghijklmnopqrstuvwxyz|~'
    ']+=)',
  );

  @override
  final ValueNotifier<CookieMap> cookie = ValueNotifier(const {});

  final Storage _storage;

  bool _initialized = false;

  @override
  NetworkRequestInterceptor get interceptor => this;

  @override
  Future<void> init() async {
    if (_initialized) return;

    cookie
      ..value = await _storage
          .get<String>(collection: 'cookie_manager', key: 'cookie')
          .then(_parseCookie)
      ..addListener(_onCookieChanged);
    _initialized = true;
  }

  @override
  FutureOr<NetworkRequestData> onRequest(NetworkRequestData data) async {
    return data.copyWith(
      headers: {
        ...data.headers,
        _effectiveCookieHeaderName: cookie.value.values
            .map((cookie) => '${cookie.name}=${cookie.value}')
            .join('; '),
      },
    );
  }

  @override
  FutureOr<NetworkResponseData> onResponse(NetworkResponseData data) {
    if (data.headers[_effectiveSetCookieHeaderName]?.isNotEmpty != true) {
      return data;
    }

    cookie.value = {
      ...cookie.value,
      ..._parseCookie(
        data.headers[_effectiveSetCookieHeaderName],
      ),
    };

    return data;
  }

  @override
  void dispose() {
    cookie.dispose();
  }

  CookieMap _parseCookie(String? setCookie) {
    if (setCookie == null) return const {};

    final List<Cookie> setCookieList = Uri.decodeComponent(setCookie)
        .split(_setCookieSplitter)
        .map(Cookie.fromSetCookieValue)
        .toList(growable: false);

    return {
      for (final Cookie cookie in setCookieList) cookie.name: cookie,
    };
  }

  void _onCookieChanged() {
    _storage.put(
      collection: 'cookie_manager',
      key: 'cookie',
      value: cookie.value.values.map((cookie) => cookie.toString()).join(','),
    );
  }
}
