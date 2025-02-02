enum MoviesOrder {
  byScore,
  byPopularity,
  byName,
  byReleaseDate,
  random;

  factory MoviesOrder.valueOf(String name) =>
      values.singleWhere((value) => name == value.name);
}
