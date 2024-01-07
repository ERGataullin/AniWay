enum MovieEpisodeTypeData {
  tv,
  movie,
  ova,
  ona,
  special,
  unknown;
}

class MovieEpisodeData {
  const MovieEpisodeData({
    required this.id,
    required this.type,
    this.number,
  });

  final int id;
  final MovieEpisodeTypeData type;
  final num? number;
}
