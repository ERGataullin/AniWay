import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '/app/domain/services/network/service.dart';

class HttpNetworkService implements NetworkService {
  HttpNetworkService({
    required this.baseUri,
  }) : _client = Client();

  @override
  final Uri baseUri;

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
    final Future<NetworkRequestData> finalData = _interceptRequest(data);

    final Future<Response> response = finalData.then(
      (data) {
        final Uri uri = baseUri.resolveUri(data.uri);
        return switch (data.method) {
          NetworkRequestMethodData.get => _client.get(
              uri,
              headers: data.headers.map(
                (key, value) => MapEntry(
                  key,
                  value.toString(),
                ),
              ),
            ),
          NetworkRequestMethodData.post => _client.post(uri),
          _ => throw UnimplementedError(),
        };
      },
    );

    return response.then(
      (response) {
        late final dynamic body;
        try {
          body = json.decode(response.body);
        } catch (error) {
          body = response.body;
        }

        return NetworkResponseData(
          body: body,
        );
      },
    ).then(_interceptResponse);
  }

  Future<NetworkRequestData> _interceptRequest(NetworkRequestData data) {
    return _interceptors.fold<Future<NetworkRequestData>>(
      Future.value(data),
      (data, interceptor) => data.then(interceptor.onRequest),
    );
  }

  Future<NetworkResponseData> _interceptResponse(NetworkResponseData data) {
    return _interceptors.fold<Future<NetworkResponseData>>(
      Future.value(data),
      (data, interceptor) => data.then(interceptor.onResponse),
    );
  }
}
