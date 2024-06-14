enum MovieType {
  tv,
  movie,
  ova,
  ona,
  special,
  tvSpecial,
  music,
  pv;

  factory MovieType.valueOf(String name) => switch (name) {
        'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieType.tv,
        'movie' => MovieType.movie,
        'ova' => MovieType.ova,
        'ona' => MovieType.ona,
        'special' => MovieType.special,
        'tv_special' => MovieType.tvSpecial,
        'music' => MovieType.music,
        'pv' || 'preview' => MovieType.pv,
        _ => throw UnimplementedError('Unimplemented movie type: $name'),
      };
}
