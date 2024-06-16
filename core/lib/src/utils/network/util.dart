import 'dart:async';

import 'package:core/core.dart';

typedef Headers = Map<String, String>;

enum RequestMethod {
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

abstract interface class Network implements Initable {
  const Network();

  Uri get baseUri;

  void addInterceptor(NetworkInterceptor interceptor);

  void removeInterceptor(NetworkInterceptor interceptor);

  Future<ResponseData> request(RequestData data);
}

abstract class NetworkInterceptor {
  const NetworkInterceptor();

  FutureOr<RequestData> onRequest(RequestData data) => data;

  FutureOr<ResponseData> onResponse(ResponseData data) => data;
}

class RequestData {
  const RequestData({
    required this.uri,
    required this.method,
    this.headers = const {},
    this.body,
  });

  final Uri uri;

  final RequestMethod method;

  final Headers headers;

  final dynamic body;

  RequestData copyWith({
    Uri? uri,
    RequestMethod? method,
    Headers? headers,
    dynamic body,
  }) =>
      RequestData(
        uri: uri ?? this.uri,
        method: method ?? this.method,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );
}

class ResponseData {
  const ResponseData({
    this.headers = const {},
    required this.body,
  });

  final Headers headers;

  final dynamic body;
}
