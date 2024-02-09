class ProxiedUri implements Uri {
  ProxiedUri({
    required this.proxy,
    required this.original,
  }) : proxied = Uri(
          scheme: proxy.scheme,
          userInfo: original.userInfo,
          host: proxy.host,
          port: proxy.port,
          path: '${original.host}:${original.port}${original.path}',
          queryParameters: {
            ...proxy.queryParameters,
            ...original.queryParameters,
          },
          fragment: original.fragment,
        );

  final Uri proxy;

  final Uri original;

  final Uri proxied;

  @override
  String get authority => proxied.authority;

  @override
  UriData? get data => proxied.data;

  @override
  String get fragment => proxied.fragment;

  @override
  bool get hasAbsolutePath => proxied.hasAbsolutePath;

  @override
  bool get hasAuthority => proxied.hasAuthority;

  @override
  bool get hasEmptyPath => proxied.hasEmptyPath;

  @override
  bool get hasFragment => proxied.hasFragment;

  @override
  bool get hasPort => proxied.hasPort;

  @override
  bool get hasQuery => proxied.hasQuery;

  @override
  bool get hasScheme => proxied.hasScheme;

  @override
  String get host => proxied.host;

  @override
  bool get isAbsolute => proxied.isAbsolute;

  @override
  bool isScheme(String scheme) => proxied.isScheme(scheme);

  @override
  Uri normalizePath() => proxied.normalizePath();

  @override
  String get origin => proxied.origin;

  @override
  String get path => proxied.path;

  @override
  List<String> get pathSegments => proxied.pathSegments;

  @override
  int get port => proxied.port;

  @override
  String get query => proxied.query;

  @override
  Map<String, String> get queryParameters => proxied.queryParameters;

  @override
  Map<String, List<String>> get queryParametersAll =>
      proxied.queryParametersAll;

  @override
  Uri removeFragment() => proxied.removeFragment();

  @override
  Uri replace({
    String? scheme,
    String? userInfo,
    String? host,
    int? port,
    String? path,
    Iterable<String>? pathSegments,
    String? query,
    Map<String, dynamic>? queryParameters,
    String? fragment,
  }) =>
      proxied.replace(
        scheme: scheme,
        userInfo: userInfo,
        host: host,
        path: path,
        pathSegments: pathSegments,
        query: query,
        queryParameters: queryParameters,
        fragment: fragment,
      );

  @override
  Uri resolve(String reference) {
    final String proxiedReference = original.resolve(reference).toString();
    return proxy.resolve(proxiedReference);
  }

  @override
  Uri resolveUri(Uri reference) {
    final Uri originalResolved = original.resolveUri(reference);
    final Uri proxiedReference = Uri(
      path: '${original.host}${originalResolved.path}',
      queryParameters: {'a': 1},
    );
    return proxy.resolveUri(proxiedReference);
  }

  @override
  String get scheme => proxied.scheme;

  @override
  String toFilePath({bool? windows}) => proxied.toFilePath(windows: windows);

  @override
  String get userInfo => proxied.userInfo;
}
