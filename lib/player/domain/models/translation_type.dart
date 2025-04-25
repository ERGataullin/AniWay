enum TranslationType {
  raw,
  sub,
  voice;

  factory TranslationType.valueOf(String name) =>
      values.singleWhere((value) => name == value.name);
}
