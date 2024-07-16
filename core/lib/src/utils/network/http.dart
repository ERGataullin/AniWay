import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart';

class HttpNetwork implements Network {
  HttpNetwork({
    required this.baseUri,
  }) : _client = Client();

  @override
  final Uri baseUri;

  final Client _client;

  final List<NetworkInterceptor> _interceptors = [];

  @override
  void init() {}

  @override
  void addInterceptor(NetworkInterceptor interceptor) =>
      _interceptors.add(interceptor);

  @override
  void removeInterceptor(NetworkInterceptor interceptor) =>
      _interceptors.remove(interceptor);

  @override
  Future<ResponseData<T>> request<T>(RequestData data) {
    return _interceptRequest(data)
        .then<ResponseData<T>>(_request)
        .then(_interceptResponse);
  }

  @override
  void dispose() {
    _client.close();
  }

  Future<RequestData> _interceptRequest(RequestData data) {
    return _interceptors.fold<Future<RequestData>>(
      Future.value(data),
      (data, interceptor) => data.then(interceptor.onRequest),
    );
  }

  Future<ResponseData<T>> _request<T>(RequestData data) async {
    final Uri uri = baseUri.resolveUri(data.uri);
    final Response httpResponse = await switch (data.method) {
      RequestMethod.get => _client.get(
          uri,
          headers: data.headers,
        ),
      RequestMethod.post => _client.post(
          uri,
          headers: data.headers,
          body: data.body,
        ),
      _ => throw UnimplementedError(),
    };

    return ResponseData(
      headers: httpResponse.headers,
      body: switch (httpResponse.body) {
        final T bodyTyped => bodyTyped,
        _ => json.decode(httpResponse.body) as T,
      },
    );
  }

  Future<ResponseData<T>> _interceptResponse<T>(ResponseData<T> data) {
    return _interceptors.fold<Future<ResponseData<T>>>(
      Future.value(data),
      (data, interceptor) => data.then(interceptor.onResponse),
    );
  }
}
