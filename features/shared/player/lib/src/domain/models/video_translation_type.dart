enum VideoTranslationType {
  raw,
  sub,
  voice;

  factory VideoTranslationType.valueOf(String name) =>
      values.singleWhere((value) => name == value.name);
}
