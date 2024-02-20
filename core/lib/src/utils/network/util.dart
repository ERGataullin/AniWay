import 'dart:async';

typedef Headers = Map<String, String>;

enum NetworkRequestMethodData {
  get,
  head,
  post,
  put,
  delete,
  connect,
  options,
  trace,
  patch;
}

abstract interface class Network {
  const Network();

  Uri get baseUri;

  void addInterceptor(NetworkRequestInterceptor interceptor);

  void removeInterceptor(NetworkRequestInterceptor interceptor);

  Future<NetworkResponseData> request(NetworkRequestData data);
}

abstract class NetworkRequestInterceptor {
  const NetworkRequestInterceptor();

  FutureOr<NetworkRequestData> onRequest(NetworkRequestData data) => data;

  FutureOr<NetworkResponseData> onResponse(NetworkResponseData data) => data;
}

class NetworkRequestData {
  const NetworkRequestData({
    required this.uri,
    required this.method,
    this.headers = const {},
    this.body,
  });

  final Uri uri;

  final NetworkRequestMethodData method;

  final Headers headers;

  final dynamic body;

  NetworkRequestData copyWith({
    Uri? uri,
    NetworkRequestMethodData? method,
    Headers? headers,
    dynamic body,
  }) =>
      NetworkRequestData(
        uri: uri ?? this.uri,
        method: method ?? this.method,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );
}

class NetworkResponseData {
  const NetworkResponseData({
    this.headers = const {},
    required this.body,
  });

  final Headers headers;

  final dynamic body;
}
