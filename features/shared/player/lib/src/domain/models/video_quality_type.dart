enum VideoQualityType {
  tv,
  dvd,
  bd;

  factory VideoQualityType.valueOf(String name) =>
      values.singleWhere((value) => name == value.name);
}
