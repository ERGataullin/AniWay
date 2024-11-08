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
    this.padding = EdgeInsets.zero,
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

  final EdgeInsets padding;

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

  late int _itemsLengthForScrollReserve;

  late SliverGridLayout _gridLayout;

  int _finishedItemsCount = 0;

  int _page = 0;

  bool _hasNextPage = true;

  Future<List<T>>? _pageFuture;

  bool get _hasUnfinishedItems => _finishedItemsCount < _items.length;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScrollReserveChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: widget.padding,
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          _handleConstraintsChanged(constraints);
          return SliverAnimatedGrid(
            key: _gridKey,
            gridDelegate: widget.gridDelegate,
            initialItemCount: _items.length,
            itemBuilder: (context, index, animation) => ListenableBuilder(
              listenable: _items[index],
              builder: (context, __) => widget.itemBuilder(
                context,
                _items[index].value,
                _animationInTween.animate(animation),
              ),
            ),
          );
        },
      ),
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

  Future<void> reload() {
    return _load(reload: true);
  }

  void _handleConstraintsChanged(SliverConstraints constraints) {
    _gridLayout = widget.gridDelegate.getLayout(constraints);
    _handleScrollReserveChanged();
  }

  void _handleScrollReserveChanged() {
    _itemsLengthForScrollReserve = _gridLayout.getMaxChildIndexForScrollOffset(
          widget.scrollController.offset +
              widget.scrollController.position.viewportDimension * 2,
        ) +
        1;
    if (_hasNextPage) _createItemsForScrollReserve();
    if (_hasUnfinishedItems) _load();
  }

  void _createItemsForScrollReserve() {
    if (_items.length >= _itemsLengthForScrollReserve) return;
    final int itemsToAddCount = _itemsLengthForScrollReserve - _items.length;
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

  Future<void> _load({
    bool reload = false,
  }) async {
    final bool loading = _pageFuture != null;
    if (!reload && (loading || !_hasNextPage)) return;

    if (reload) {
      for (int index = _items.length - 1;
          index > _itemsLengthForScrollReserve;
          index--) {
        final ValueNotifier<T?> item = _items.removeAt(index);
        _gridKey.currentState?.removeItem(
          index,
          (context, animation) => widget.itemBuilder(
            context,
            item.value,
            _animationOutTween.animate(animation),
          ),
        );
        item.dispose();
      }
      for (int i = 0; i < _items.length; i++) {
        _items[i].value = null;
      }
      _finishedItemsCount = 0;
    }

    final int page = reload ? 1 : _page + 1;
    final Future<List<T>> pageFuture = widget.loader(page);
    _pageFuture = pageFuture;

    final List<T> newItems = await pageFuture;
    if (_pageFuture != pageFuture) return;

    _pageFuture = null;
    _hasNextPage = newItems.isNotEmpty;
    _page = page;
    for (int newItemsIndex = 0;
        newItemsIndex < newItems.length;
        newItemsIndex++) {
      final int itemsIndex = _finishedItemsCount + newItemsIndex;
      final T item = newItems[newItemsIndex];
      if (_items.length > itemsIndex) {
        _items[itemsIndex].value = item;
      } else {
        _items.add(ValueNotifier(item));
        _gridKey.currentState?.insertItem(itemsIndex);
      }
    }

    _finishedItemsCount += newItems.length;
    if (_hasUnfinishedItems) _load();
  }
}
