enum MovieEpisodeTypeData {
  tv,
  movie,
  ova,
  ona,
  special,
  tvSpecial,
  pv,
  unknown;
}

class MovieEpisodeData {
  const MovieEpisodeData({
    required this.id,
    required this.type,
    this.number,
  });

  final Object id;
  final MovieEpisodeTypeData type;
  final num? number;
}
