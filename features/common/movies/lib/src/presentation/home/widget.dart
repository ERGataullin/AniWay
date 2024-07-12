import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/components/movie_preview.dart';
import 'package:movies/src/presentation/home/wm.dart';

extension _HomeContext on BuildContext {
  IHomeWM get wm => read<IHomeWM>();
}

class HomeWidget extends ElementaryWidget<IHomeWM> {
  const HomeWidget({
    super.key,
    required this.onUpNextPressed,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = homeWMFactory,
  }) : super(wmFactory);

  final void Function(Object movieId, Object episodeId) onUpNextPressed;

  final void Function(Object id) onMoviePressed;

  @override
  Widget build(IHomeWM wm) {
    return Provider<IHomeWM>.value(
      value: wm,
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: wm.title,
            builder: (context, title, ___) => Text(title),
          ),
        ),
        body: ListenableBuilder(
          listenable: wm.showLoader,
          builder: (context, __) => AnimatedSwitcher(
            switchInCurve: Curves.easeInOutCubicEmphasized,
            switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
            duration: Durations.long2,
            child: wm.showLoader.value
                ? const Center(child: CircularProgressIndicator.adaptive())
                : const _Content(),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    const EdgeInsets categoriesMargin = EdgeInsets.symmetric(horizontal: 16);
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(
          top: 16 + safeAreaPadding.top,
          bottom: 16 + safeAreaPadding.bottom,
        ),
        child: Column(
          children: [
            _Category(
              margin: categoriesMargin,
              label: context.wm.upNextLabel,
              movies: context.wm.upNextItems,
              ),
            Divider(
              indent: 16 + safeAreaPadding.left,
              endIndent: 16 + safeAreaPadding.right,
              height: 32,
            ),
            _Category(
              margin: categoriesMargin,
              label: context.wm.popularLabel,
              movies: context.wm.popularItems,
            ),
          ],
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    this.margin = EdgeInsets.zero,
    required this.label,
    required this.movies,
  });

  final EdgeInsets margin;

  final ValueListenable<String> label;

  final ValueListenable<List<MoviePreviewData>> movies;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets horizontalMargin = EdgeInsets.only(
      left: margin.left,
      right: margin.right,
    );
    final EdgeInsets verticalMargin = EdgeInsets.only(
      top: margin.top,
      bottom: margin.bottom,
    );

    return Padding(
      padding: verticalMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: horizontalMargin,
              child: ValueListenableBuilder<String>(
                valueListenable: label,
                builder: (context, label, ___) => Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Movies(
            margin: margin,
            movies: movies,
          ),
        ],
      ),
    );
  }
}

class _Movies extends StatelessWidget {
  const _Movies({
    this.margin = EdgeInsets.zero,
    required this.movies,
  });

  final EdgeInsets margin;

  final ValueListenable<List<MoviePreviewData>> movies;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    return SizedBox(
      height: 256,
      child: ValueListenableBuilder(
        valueListenable: movies,
        builder: (context, movies, ___) => ListView.separated(
          clipBehavior: Clip.none,
          itemCount: movies.length,
          padding: margin.add(
            EdgeInsets.only(
              left: safeAreaPadding.left,
              right: safeAreaPadding.right,
            ),
          ),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => MoviePreview(movies[index]),
        ),
      ),
    );
  }
}
