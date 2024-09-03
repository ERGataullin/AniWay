import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/episodes/wm.dart';

class EpisodesWidget extends ElementaryWidget<IEpisodesWM> {
  const EpisodesWidget({
    super.key,
    WidgetModelFactory wmFactory = episodesWMFactory,
  }) : super(wmFactory);

  @override
  Widget build(IEpisodesWM wm) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Список эпизодов'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: '1-20',
              ),
              Tab(
                text: '21-40',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
