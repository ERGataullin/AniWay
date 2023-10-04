import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '/app/domain/services/network/service.dart';

class HttpNetworkService implements NetworkService {
  HttpNetworkService({
    required String baseUrl,
  })  : _client = Client(),
        _baseUrl = baseUrl;

  final Client _client;
  final String _baseUrl;
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

    final Uri uri = Uri.parse('$_baseUrl${data.uri}');

    final Future<Response> response = finalData.then(
      (data) => switch (data.method) {
        NetworkRequestMethodData.get => _client.get(uri),
        NetworkRequestMethodData.post => _client.post(uri),
        _ => throw UnimplementedError(),
      },
    );

    return response
        .then(
          (response) => NetworkResponseData(
            body: json.decode(response.body),
          ),
        )
        .then(_interceptResponse);
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
