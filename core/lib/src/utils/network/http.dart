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

  @override
  String csrf = '';

  final Client _client;

  final List<NetworkRequestInterceptor> _interceptors = [];

  @override
  void addInterceptor(NetworkRequestInterceptor interceptor) =>
      _interceptors.add(interceptor);

  @override
  void removeInterceptor(NetworkRequestInterceptor interceptor) =>
      _interceptors.remove(interceptor);

  @override
  Future<NetworkResponseData> request(NetworkRequestData data) {
    return _interceptRequest(data).then(_request).then(_interceptResponse);
  }

  Future<NetworkRequestData> _interceptRequest(NetworkRequestData data) {
    return _interceptors.fold<Future<NetworkRequestData>>(
      Future.value(data),
      (data, interceptor) => data.then(interceptor.onRequest),
    );
  }

  Future<NetworkResponseData> _request(NetworkRequestData data) async {
    final Uri uri = baseUri.resolveUri(data.uri);
    final Response httpResponse = await switch (data.method) {
      NetworkRequestMethodData.get => _client.get(
          uri,
          headers: data.headers,
        ),
      NetworkRequestMethodData.post => _client.post(
          uri,
          headers: data.headers,
          body: data.body,
        ),
      _ => throw UnimplementedError(),
    };

    late final dynamic body;
    try {
      body = json.decode(httpResponse.body);
    } catch (error) {
      body = httpResponse.body;
    }

    return NetworkResponseData(
      headers: httpResponse.headers,
      body: body,
    );
  }

  Future<NetworkResponseData> _interceptResponse(NetworkResponseData data) {
    return _interceptors.fold<Future<NetworkResponseData>>(
      Future.value(data),
      (data, interceptor) => data.then(interceptor.onResponse),
    );
  }

}
