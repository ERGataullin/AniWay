import 'dart:async';
import 'dart:io';

import 'package:app/core/core.dart';
import 'package:flutter/foundation.dart';

typedef CookieMap = Map<String, Cookie>;

extension CookieDecoded on Cookie {
  String get valueDecoded => Uri.decodeComponent(value);
}

class CookieManager extends NetworkInterceptor with Initable {
  CookieManager({
    required bool useCustomCookieHeader,
    required StorageService storageService,
  }) : _useCustomCookieHeader = useCustomCookieHeader,
       _storageService = storageService;

  static final Pattern _setCookieSplitter = RegExp(
    r'[ \t]*,[ \t]*(?=['
    r"!#$%&'*+\-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`"
    'abcdefghijklmnopqrstuvwxyz|~'
    ']+=)',
  );

  final ValueNotifier<CookieMap> cookie = ValueNotifier(const {});

  final bool _useCustomCookieHeader;

  final StorageService _storageService;

  NetworkInterceptor get interceptor => this;

  String get _cookieHeaderName =>
      _useCustomCookieHeader ? 'kaki' : HttpHeaders.cookieHeader;

  String get _setCookieHeaderName =>
      _useCustomCookieHeader ? 'set-kaki' : HttpHeaders.setCookieHeader;

  @override
  Future<void> init() async {
    super.init();
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
        _cookieHeaderName: cookie.value.values
            .map((cookie) => '${cookie.name}=${cookie.value}')
            .join(';'),
      },
    );
  }

  @override
  FutureOr<ResponseData<T>> handleResponse<T>(ResponseData<T> data) {
    if (data.headers[_setCookieHeaderName]?.isEmpty ?? true) return data;
    cookie.value = {
      ...cookie.value,
      ..._parseCookie(data.headers[_setCookieHeaderName]),
    };
    return data;
  }

  @override
  void dispose() {
    cookie.dispose();
    super.dispose();
  }

  CookieMap _parseCookie(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) return const {};

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
