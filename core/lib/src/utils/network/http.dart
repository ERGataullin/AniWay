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
            'Kaki':
                'fv=1680200569; guestId=203d952a701be1994fecdce061e4d4e1466878c1bbc398bd5645273935346380; csrf=UzdsZHkxeEl6cFJJeXNlamVPNnR1R2hJbUVGTGlTTlIN6vXsANs9h1bSrox-Y1sFd5UiuDl5AqEQH4aKSzzrhQ%3D%3D; _ym_uid=1680200565887331930; ads-blocked=0; _ym_d=1696157952; hasOneSignalUserId=1; lastTranslationType=voiceRu; _ym_isad=1; _ym_hostIndex=0-13%2C1-0; PHPSESSID=ghe14vb8pb6c3rjdfb83okej91; aaaa8ed0da05b797653c4bd51877d861=154604a8cbd1e82745cf96767142f3430858c28aa%3A4%3A%7Bi%3A0%3Bi%3A210324%3Bi%3A1%3Bs%3A5%3A%22Edgar%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222022-03-26+13%3A16%3A05%22%3B%7D%'
          },
        ),
      NetworkRequestMethodData.post => _client.post(
          uri,
          headers: {
            'Kaki':
                'fv=1680200569; guestId=203d952a701be1994fecdce061e4d4e1466878c1bbc398bd5645273935346380; csrf=UzdsZHkxeEl6cFJJeXNlamVPNnR1R2hJbUVGTGlTTlIN6vXsANs9h1bSrox-Y1sFd5UiuDl5AqEQH4aKSzzrhQ%3D%3D; _ym_uid=1680200565887331930; ads-blocked=0; _ym_d=1696157952; hasOneSignalUserId=1; lastTranslationType=voiceRu; _ym_isad=1; _ym_hostIndex=0-5%2C1-0; watchedVideoToday=1; PHPSESSID=b6f06o89kbpdgsi0nidc9jt6c9; aaaa8ed0da05b797653c4bd51877d861=154604a8cbd1e82745cf96767142f3430858c28aa%3A4%3A%7Bi%3A0%3Bi%3A210324%3Bi%3A1%3Bs%3A5%3A%22Edgar%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222022-03-26+13%3A16%3A05%22%3B%7D%7D'
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
