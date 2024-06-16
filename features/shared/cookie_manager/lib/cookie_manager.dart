import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

typedef CookieMap = Map<String, Cookie>;

abstract class CookieManager implements Initable {
  ValueListenable<CookieMap> get cookie;

  NetworkInterceptor get interceptor;

  String? get csrf;
}

class CookieManagerImpl extends NetworkInterceptor implements CookieManager {
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

  @override
  NetworkInterceptor get interceptor => this;

  @override
  String? get csrf => cookie.value['csrf']?.value.isEmpty ?? true
      ? null
      : Uri.decodeComponent(cookie.value['csrf']!.value);

  @override
  Future<void> init() async {
    cookie
      ..value = await _storage
          .get<String>(collection: 'cookie_manager', key: 'cookie')
          .then(_parseCookie)
      ..addListener(_onCookieChanged);
  }

  @override
  FutureOr<RequestData> onRequest(RequestData data) {
    return data.copyWith(
      headers: {
        ...data.headers,
        _effectiveCookieHeaderName: cookie.value.values
            .map((cookie) => '${cookie.name}=${cookie.value}')
            .join(';'),
      },
    );
  }

  @override
  FutureOr<ResponseData> onResponse(ResponseData data) {
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

    final List<Cookie> setCookieList = setCookie
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
