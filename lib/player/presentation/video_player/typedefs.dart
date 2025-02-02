import 'package:app/player/player.dart';

typedef VideoResolver = Future<VideoData> Function(int translationId);

typedef TranslationWatchedCallback = void Function(int translationId);
