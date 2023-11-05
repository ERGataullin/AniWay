class NetworkResponseData {
  const NetworkResponseData({
    this.headers = const {},
    required this.body,
  });

  final Map<String, String> headers;
  final dynamic body;
}
