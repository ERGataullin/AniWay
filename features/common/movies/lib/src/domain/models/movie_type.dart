enum MovieTypeData {
  tv,
  movie,
  ova,
  ona,
  special,
  tvSpecial,
  music,
  pv;

  factory MovieTypeData.valueOf(String name) => switch (name) {
        'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieTypeData.tv,
        'movie' => MovieTypeData.movie,
        'ova' => MovieTypeData.ova,
        'ona' => MovieTypeData.ona,
        'special' => MovieTypeData.special,
        'tv_special' => MovieTypeData.tvSpecial,
        'music' => MovieTypeData.music,
        'pv' || 'preview' => MovieTypeData.pv,
        _ => throw UnimplementedError('Unimplemented movie type: $name'),
      };
}
