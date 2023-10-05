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

class NetworkRequestData {
  const NetworkRequestData({
    required this.uri,
    required this.method,
    this.headers = const {},
    this.body,
  });

  final Uri uri;
  final NetworkRequestMethodData method;
  final Map<String, dynamic> headers;
  final dynamic body;

  NetworkRequestData copyWith({
    Uri? uri,
    NetworkRequestMethodData? method,
    Map<String, dynamic>? headers,
    dynamic body,
  }) =>
      NetworkRequestData(
        uri: uri ?? this.uri,
        method: method ?? this.method,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );
}
