import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/presentation/components/movie_preview/widget.dart';
import 'package:movies/src/presentation/search/widget_model.dart';
import 'package:provider/provider.dart';

extension _SearchContext on BuildContext {
  ISearchWidgetModel get wm => read<ISearchWidgetModel>();
}

class SearchWidget extends ElementaryWidget<ISearchWidgetModel> {
  const SearchWidget({
    super.key,
    required this.onMoviePressed,
    WidgetModelFactory wmFactory = searchWidgetModelFactory,
  }) : super(wmFactory);

  final void Function(int id) onMoviePressed;

  @override
  Widget build(ISearchWidgetModel wm) {
    return Provider<ISearchWidgetModel>.value(
      value: wm,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchBar(),
            _Result(),
            _Loader(),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SearchAnchor(
        suggestionsBuilder: (context, controller) => [
          const SizedBox.shrink(),
        ],
        builder: (context, controller) => ValueListenableBuilder(
          valueListenable: context.wm.hintText,
          builder: (context, hintText, ___) => SearchBar(
            controller: context.wm.queryController,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            leading: const Icon(Icons.search),
            hintText: hintText,
          ),
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: context.wm.showResult,
        builder: (context, showResult, ___) => Visibility(
          visible: showResult,
          child: ValueListenableBuilder(
            valueListenable: context.wm.movies,
            builder: (context, items, ___) => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: MoviePreviewWidget.aspectRatio,
                maxCrossAxisExtent: 200,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => MoviePreviewWidget(
                movie: items[index],
                onPressed: () => context.wm.onMoviePressed(items[index].id),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: context.wm.showLoader,
          builder: (context, showLoader, ___) => Visibility(
            visible: showLoader,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
