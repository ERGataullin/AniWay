enum QualityType {
  tv,
  dvd,
  bd;

  factory QualityType.valueOf(String name) =>
      values.singleWhere((value) => name == value.name);
}
