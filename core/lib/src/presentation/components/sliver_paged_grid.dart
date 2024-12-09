import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnLoadPage<T> = Future<List<T>> Function(int page);

typedef PagedGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  Animation<double> animation,
);

class SliverPagedGrid<T> extends StatefulWidget {
  const SliverPagedGrid({
    super.key,
    required this.scrollController,
    this.animationInCurve = defaultAnimationInCurve,
    this.animationInDuration = defaultAnimationInDuration,
    this.animationOutCurve = defaultAnimationOutCurve,
    this.animationOutDuration = defaultAnimationOutDuration,
    required this.gridDelegate,
    required this.loader,
    required this.itemBuilder,
  });

  static const Curve defaultAnimationInCurve = Easing.standardDecelerate;

  static const Duration defaultAnimationInDuration = Durations.medium1;

  static const Curve defaultAnimationOutCurve = FlippedCurve(
    Easing.standardAccelerate,
  );

  static const Duration defaultAnimationOutDuration = Durations.short4;

  final ScrollController scrollController;

  final Curve animationInCurve;

  final Duration animationInDuration;

  final Curve animationOutCurve;

  final Duration animationOutDuration;

  final SliverGridDelegate gridDelegate;

  final OnLoadPage<T> loader;

  final PagedGridItemBuilder<T?> itemBuilder;

  @override
  State<SliverPagedGrid<T>> createState() => SliverPagedGridState();
}

class SliverPagedGridState<T> extends State<SliverPagedGrid<T>> {
  final GlobalKey<SliverAnimatedGridState> _gridKey = GlobalKey();

  final List<ValueNotifier<T?>> _items = [];

  late final CurveTween _animationInTween = CurveTween(
    curve: widget.animationInCurve,
  );

  late final CurveTween _animationOutTween = CurveTween(
    curve: widget.animationOutCurve,
  );

  late int _scrollReserveItemsLength;

  int _finishedItemsCount = 0;

  int _page = 0;

  bool _hasNextPage = true;

  Future<List<T>>? _pageFuture;

  bool get _hasUnfinishedItems => _finishedItemsCount < _items.length;

  bool get _loading => _pageFuture != null;

  Future<void> reload() {
    return _load(reload: true);
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        _handleConstraintsChanged(constraints);
        return SliverAnimatedGrid(
          key: _gridKey,
          gridDelegate: widget.gridDelegate,
          initialItemCount: _items.length,
          itemBuilder: (context, index, animation) {
            _handleItemBuildCalled(context, index);
            return ListenableBuilder(
              listenable: _items[index],
              builder: (context, __) => widget.itemBuilder(
                context,
                _items[index].value,
                _animationInTween.animate(animation),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _pageFuture = null;
    for (final ValueNotifier<T?> item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _handleConstraintsChanged(SliverConstraints constraints) {
    final SliverGridLayout gridLayout =
        widget.gridDelegate.getLayout(constraints);
    _scrollReserveItemsLength = gridLayout.getMaxChildIndexForScrollOffset(
      widget.scrollController.position.viewportDimension,
    );
    if (_hasNextPage) _createScrollReserveItems();
    if (_hasUnfinishedItems) _load();
  }

  void _createScrollReserveItems() {
    assert(_hasNextPage);
    final double filledViewportsCount =
        _items.length / _scrollReserveItemsLength;
    final double positionInViewports = widget.scrollController.offset /
            widget.scrollController.position.viewportDimension +
        1;
    final double viewportsToFillCount =
        positionInViewports - filledViewportsCount + 1;
    if (viewportsToFillCount <= 0) return;

    final int itemsToAddCount =
        (_scrollReserveItemsLength * viewportsToFillCount).ceil();
    _gridKey.currentState?.insertAllItems(
      _items.length,
      itemsToAddCount,
      duration: widget.animationInDuration,
    );
    _items.addAll(
      Iterable.generate(
        itemsToAddCount,
        (index) => ValueNotifier(null),
      ),
    );
  }

  void _handleItemBuildCalled(BuildContext context, int index) {
    if (!widget.scrollController.position.hasContentDimensions) return;
    final bool hasScrollReserve = widget.scrollController.position.extentAfter >
        widget.scrollController.position.viewportDimension;
    if (!hasScrollReserve && _hasNextPage) _createScrollReserveItems();
    if (_hasUnfinishedItems) _load();
  }

  Future<void> _load({
    bool reload = false,
  }) async {
    final bool loading = _pageFuture != null;
    if (!reload && (loading || !_hasNextPage)) return;

    if (reload) _removeLastItems();
    _createScrollReserveItems();

    final int page = reload ? 1 : _page + 1;
    final Future<List<T>> pageFuture = widget.loader(page);
    _pageFuture = pageFuture;

    final List<T> newItems = await pageFuture;
    if (_pageFuture != pageFuture) return;

    _pageFuture = null;
    _hasNextPage = newItems.isNotEmpty;
    _page = page;
    for (int i = 0; i < newItems.length; i++) {
      final int itemsIndex = _finishedItemsCount + i;
      final T item = newItems[i];
      if (_items.length > itemsIndex) {
        _items[itemsIndex].value = item;
      } else {
        _items.add(ValueNotifier(item));
        _gridKey.currentState?.insertItem(
          itemsIndex,
          duration: widget.animationInDuration,
        );
      }
    }

    _finishedItemsCount += newItems.length;
    if (!_hasNextPage) _removeLastItems(lastToKeep: _finishedItemsCount - 1);
    if (_hasNextPage && _hasUnfinishedItems) _load();
  }

  Future<void> _removeLastItems({int lastToKeep = -1}) async {
    for (int i = _items.length - 1; i > lastToKeep; i--) {
      final ValueNotifier<T?> item = _items.removeAt(i);
      _gridKey.currentState?.removeItem(
        i,
        (context, animation) => widget.itemBuilder(
          context,
          item.value,
          _animationOutTween.animate(animation),
        ),
        duration: widget.animationOutDuration,
      );
      item.dispose();
    }
    for (int i = 0; i < _items.length; i++) {
      _items[i].value = null;
    }
    if (lastToKeep < _finishedItemsCount) _finishedItemsCount = lastToKeep;

    await Future<void>.delayed(widget.animationOutDuration);
  }
}
