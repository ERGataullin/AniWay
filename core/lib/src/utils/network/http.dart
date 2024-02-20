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
          headers: {
            'kaki':
                'fv=1708203948; guestId=acee8e93bfe75f8432456d43080c206c0f2806703d8c4eda0af41900187ab105; csrf=cmdwRFVDYUlJUVZaTDVhZlhHTmpQemk4dTc1ZDYyNVJW-011moPHrKuKFZUaGMut1hEFto73aNqfWxb3IiQ2KQ%3D%3D; _ym_uid=1680200565887331930; _ym_d=1708203946; ads-blocked=0; hasOneSignalUserId=1; _ym_hostIndex=0-26%2C1-0; _ym_isad=1; watchedVideoToday=1; PHPSESSID=ru4mcvgfbsg0i9tt89f33g0gjl; aaaa8ed0da05b797653c4bd51877d861=154604a8cbd1e82745cf96767142f3430858c28aa%3A4%3A%7Bi%3A0%3Bi%3A210324%3Bi%3A1%3Bs%3A5%3A%22Edgar%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222022-03-26+13%3A16%3A05%22%3B%7D%7D'
          },
        ),
      NetworkRequestMethodData.post => _client.post(
          uri,
          headers: {
            'kaki':
                'fv=1708203948; guestId=acee8e93bfe75f8432456d43080c206c0f2806703d8c4eda0af41900187ab105; csrf=cmdwRFVDYUlJUVZaTDVhZlhHTmpQemk4dTc1ZDYyNVJW-011moPHrKuKFZUaGMut1hEFto73aNqfWxb3IiQ2KQ%3D%3D; _ym_uid=1680200565887331930; _ym_d=1708203946; ads-blocked=0; hasOneSignalUserId=1; _ym_hostIndex=0-26%2C1-0; _ym_isad=1; watchedVideoToday=1; PHPSESSID=ru4mcvgfbsg0i9tt89f33g0gjl; aaaa8ed0da05b797653c4bd51877d861=154604a8cbd1e82745cf96767142f3430858c28aa%3A4%3A%7Bi%3A0%3Bi%3A210324%3Bi%3A1%3Bs%3A5%3A%22Edgar%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222022-03-26+13%3A16%3A05%22%3B%7D%7D'
          },
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
