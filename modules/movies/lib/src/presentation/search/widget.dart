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
    WidgetModelFactory wmFactory = searchWidgetModelFactory,
  }) : super(wmFactory);

  @override
  Widget build(ISearchWidgetModel wm) {
    return Provider<ISearchWidgetModel>.value(
      value: wm,
      child: Scaffold(
        body: Column(
          children: [
            _SearchBar(),
            _Result(),
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
          SizedBox.shrink(),
        ],
        builder: (context, controller) => ValueListenableBuilder(
          valueListenable: context.wm.hintText,
          builder: (context, hintText, ___) {
            return SearchBar(
              controller: context.wm.searchController,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              leading: const Icon(Icons.search),
              hintText: hintText,
            );
          },
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
        valueListenable: context.wm.moviesByQuery,
        builder: (context, items, ___) => GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: MoviePreviewWidget.aspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return MoviePreviewWidget(
              movie: items[index],
              onPressed: () {},
            );
          },
        ),
      ),
    );
  }
}
