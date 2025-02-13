import 'dart:async';
import 'dart:io';

import 'package:app/core/core.dart';
import 'package:flutter/foundation.dart';

typedef CookieMap = Map<String, Cookie>;

extension CookieDecoded on Cookie {
  String get valueDecoded => Uri.decodeComponent(value);
}

abstract class CookieManager implements Initable {
  ValueListenable<CookieMap> get cookie;

  NetworkInterceptor get interceptor;
}

class CookieManagerImpl extends NetworkInterceptor implements CookieManager {
  CookieManagerImpl({required StorageService storageService})
    : _storageService = storageService;

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

  final StorageService _storageService;

  @override
  NetworkInterceptor get interceptor => this;

  @override
  Future<void> init() async {
    cookie
      ..value = await _storageService
          .get<String?>(
            collection: 'cookie_manager',
            key: 'cookie',
            defaultValue: null,
          )
          .then(_parseCookie)
      ..addListener(_handleCookieChanged);
  }

  @override
  FutureOr<RequestData> handleRequest(RequestData data) {
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
  FutureOr<ResponseData<T>> handleResponse<T>(ResponseData<T> data) {
    if (data.headers[_effectiveSetCookieHeaderName]?.isNotEmpty != true) {
      return data;
    }

    cookie.value = {
      ...cookie.value,
      ..._parseCookie(data.headers[_effectiveSetCookieHeaderName]),
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

    return {for (final Cookie cookie in setCookieList) cookie.name: cookie};
  }

  void _handleCookieChanged() {
    _storageService.put<String?>(
      collection: 'cookie_manager',
      key: 'cookie',
      value: cookie.value.values.map((cookie) => cookie.toString()).join(','),
    );
  }
}
