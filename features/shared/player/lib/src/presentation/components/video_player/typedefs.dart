import 'package:player/player.dart';

typedef VideoResolver = Future<VideoData> Function(Object translationId);

typedef TranslationWatchedCallback = void Function(Object translationId);
