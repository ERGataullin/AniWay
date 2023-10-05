class RouteDefinitionData {
  const RouteDefinitionData(this.uri);

  factory RouteDefinitionData.parse(String path) =>
      RouteDefinitionData(Uri.parse(path));

  final Uri uri;

  String get path => uri.toString();
}
