class RouteDefinition {
  const RouteDefinition(this.uri);

  factory RouteDefinition.parse(String path) =>
      RouteDefinition(Uri.parse(path));

  final Uri uri;

  String get path => uri.toString();
}
