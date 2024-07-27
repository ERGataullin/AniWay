enum VideoTranslationType {
  raw,
  sub,
  voice;

  factory VideoTranslationType.valueOf(String name) =>
      values.singleWhere((value) => value.name == name);
}
