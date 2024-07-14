import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

typedef PagedLoader<T> = Future<List<T>> Function(int page);

class SliverPagedGrid<T> extends StatefulWidget {
  const SliverPagedGrid({
    super.key,
    required this.scrollController,
    required this.spacing,
    required this.gridDelegate,
    required this.pageSize,
    required this.loader,
    required this.itemBuilder,
  });

  final ScrollController scrollController;

  final double spacing;

  final SliverGridDelegate gridDelegate;

  final int pageSize;

  final PagedLoader<T> loader;

  final ValueWidgetBuilder<T> itemBuilder;

  @override
  State<SliverPagedGrid<T>> createState() => SliverPagedGridState();
}

class SliverPagedGridState<T> extends State<SliverPagedGrid<T>> {
  final ValueNotifier<bool> _showLoader = ValueNotifier(false);

  final ValueNotifier<bool> _centerLoader = ValueNotifier(false);

  final ValueNotifier<List<T>> _items = ValueNotifier(const []);

  int _page = 0;

  bool _hasNextPage = true;

  Future<List<T>>? _pageFuture;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_ensureHasScrollReserve);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        ValueListenableBuilder(
          valueListenable: _items,
          builder: (context, movies, ___) => SliverGrid.builder(
            gridDelegate: widget.gridDelegate,
            itemCount: movies.length,
            itemBuilder: (context, index) => widget.itemBuilder(
              context,
              _items.value[index],
              null,
            ),
          ),
        ),
        ListenableBuilder(
          listenable: _centerLoader,
          builder: (context, child) => _centerLoader.value
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: child,
                )
              : SliverToBoxAdapter(child: child),
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: _showLoader,
              child: Padding(
                padding: EdgeInsets.only(top: widget.spacing),
                child: const CircularProgressIndicator.adaptive(),
              ),
              builder: (context, showLoader, child) =>
                  AnimatedVisibility.standard(
                visible: showLoader,
                child: child!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _showLoader.dispose();
    _centerLoader.dispose();
    _items.dispose();
    widget.scrollController.removeListener(_ensureHasScrollReserve);
    super.dispose();
  }

  Future<void> reload() {
    return _load(reload: true);
  }

  void _ensureHasScrollReserve() {
    final bool hasScrollReserve = widget.scrollController.position.extentAfter >
        widget.scrollController.position.viewportDimension;
    if (!hasScrollReserve) _load();
  }

  Future<void> _load({
    bool reload = false,
  }) async {
    if (!reload && (_showLoader.value || !_hasNextPage)) return;

    if (reload) _items.value = const [];
    _centerLoader.value = reload || _items.value.isEmpty;
    _showLoader.value = true;
    final int page = reload ? 1 : _page + 1;
    final Future<List<T>> pageFuture = widget.loader(page);
    _pageFuture = pageFuture;
    final List<T> newItems = await pageFuture;

    if (_pageFuture != pageFuture) return;

    _pageFuture = null;
    _hasNextPage = newItems.length >= widget.pageSize;
    _items.value = List.unmodifiable([..._items.value, ...newItems]);
    _page = page;
    _showLoader.value = false;

    await WidgetsBinding.instance.endOfFrame;
    _ensureHasScrollReserve();
  }
}
