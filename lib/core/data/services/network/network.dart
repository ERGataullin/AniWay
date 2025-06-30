import 'dart:async';

import 'package:app/core/core.dart';

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
  patch,
}

abstract interface class NetworkService with Initable {
  const NetworkService();

  Uri get baseUri;

  void addInterceptor(NetworkInterceptor interceptor);

  void removeInterceptor(NetworkInterceptor interceptor);

  Future<ResponseData<T>> request<T>(RequestData data);
}

abstract class NetworkInterceptor {
  const NetworkInterceptor();

  FutureOr<RequestData> handleRequest(RequestData data) => data;

  FutureOr<ResponseData<T>> handleResponse<T>(ResponseData<T> data) => data;
}

class RequestData {
  const RequestData({
    required this.method,
    required this.uri,
    this.headers = const {},
    this.body,
  });

  final RequestMethod method;

  final Uri uri;

  final Headers headers;

  final Object? body;

  RequestData copyWith({
    RequestMethod? method,
    Uri? uri,
    Headers? headers,
    Object? body,
  }) => RequestData(
    method: method ?? this.method,
    uri: uri ?? this.uri,
    headers: headers ?? this.headers,
    body: body ?? this.body,
  );
}

class ResponseData<T> {
  const ResponseData({this.headers = const {}, required this.body});

  final Headers headers;

  final T body;
}
