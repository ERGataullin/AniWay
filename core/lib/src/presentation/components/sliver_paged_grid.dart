import 'dart:math' as math;

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
    required this.controller,
    required this.gridDelegate,
    required this.onLoadPage,
    required this.itemBuilder,
  });

  final ScrollController controller;

  final SliverGridDelegate gridDelegate;

  final OnLoadPage<T> onLoadPage;

  final PagedGridItemBuilder<T?> itemBuilder;

  @override
  State<SliverPagedGrid<T>> createState() => SliverPagedGridState();
}

class SliverPagedGridState<T> extends State<SliverPagedGrid<T>> {
  /// Ключ [SliverAnimatedGrid].
  ///
  /// Используется для информирования состояния [SliverAnimatedGridState]
  /// о добавлении/удалении элементов.
  final GlobalKey<SliverAnimatedGridState> _gridKey = GlobalKey();

  /// Элементы страниц.
  final List<ValueNotifier<T?>> _items = [];

  /// Кол-во элементов, необходимое для заполнения вьюпорта.
  late int _viewportCapacity;

  /// Кол-во элементов, помещающихся в 1-у строку.
  late int _crossAxisCount;

  /// Существует ли след. страница.
  ///
  /// Принимает значение `false`, если на запрос страницы был получен
  /// пустой список элементов.
  bool _hasNextPage = true;

  /// Кол-во завершённых элементов (не плэйсхолдеров).
  int _finishedItemsCount = 0;

  /// Номер последней непустой полученной страницы.
  int _page = 0;

  /// Выполняемый запрос страницы.
  Future<void>? _pendingPageRequest;

  /// Выполняется ли запрос страницы.
  bool get _isPending => _pendingPageRequest != null;

  /// Имеются ли плэйсхолдеры.
  bool get _hasPlaceholders => _items.length > _finishedItemsCount;

  /// Сбрасывает состояние.
  ///
  /// Очищает все данные и незамедлительно запрашивает 1-ю страницу.
  Future<void> reset() async {
    // Скролл в начало списка.
    widget.controller.animateTo(
      0,
      duration: Durations.long2,
      curve: Curves.easeInOutCubicEmphasized,
    );
    // Удаление лишних элементов, оставляя лишь необходимые для сохранения
    // резерва скролла, и замена оставшихся плэйсхолдерами.
    final int placeholdersToKeep =
        math.min(_viewportCapacity * 2, _items.length);
    _removeItems(from: placeholdersToKeep);
    for (int i = 0; i < placeholdersToKeep; i++) {
      _items[i].value = null;
    }
    _finishedItemsCount = 0;
    _page = 0;
    _hasNextPage = true;
    _ensureHasScrollReserve();

    // Игнорирование предыдущей запрошенной страницы, если она ещё не получена.
    _pendingPageRequest?.ignore();
    _pendingPageRequest = null;

    // Запрос 1-й страницы.
    await _loadNextPage();
  }

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  @override
  void dispose() {
    for (final ValueNotifier<T?> item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CurveTween curveTween = CurveTween(curve: Easing.standardDecelerate);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // TODO(Edgar): После reset'а в данном месте оффсет скролла ещё не успел
        // сброситься, в результате чего сразу же создаются плэйсхолдеры и при
        // поиске не происходит скролл в начало списка. Убедиться, что переход
        // на SliverAnimatedGrid решает проблему.
        _handleConstraintsChanged(constraints);
        return SliverAnimatedGrid(
          key: _gridKey,
          gridDelegate: widget.gridDelegate,
          initialItemCount: _items.length,
          itemBuilder: (context, index, animation) {
            _handleItemBuildCalled(index);
            return ListenableBuilder(
              listenable: _items[index],
              builder: (context, __) => widget.itemBuilder(
                context,
                _items[index].value,
                curveTween.animate(animation),
              ),
            );
          },
        );
      },
    );
  }

  /// Получает след. страницу.
  ///
  /// Запрос не будет инициирован, если запрос страницы
  /// уже выполняется (значение [_isPending] равно `true`)
  /// или страница не существует (значение [_hasNextPage] равно `false`).
  /// После получения страницы автоматически запрашивает уже следующую, если
  /// остались плэйсхолдеры.
  Future<void> _loadNextPage() async {
    // Выход, если запрос след. страницы уже выполняется или она не существует.
    if (_isPending || !_hasNextPage) return;

    // Инициирование запроса страницы.
    final Future<List<T>> pageRequest = widget.onLoadPage(_page + 1);
    _pendingPageRequest = pageRequest;
    final List<T> pageItems = await pageRequest;

    // Выход, если данный запрос не является актуальным.
    if (pageRequest != _pendingPageRequest) return;
    _pendingPageRequest = null;
    // Установление несуществования страницы и выход, если страница пустая.
    if (pageItems.isEmpty) {
      _hasNextPage = false;
      _removeItems(from: _finishedItemsCount);
      return;
    }

    // Кол-во плэйсхолдеров, которые нужно заменить элементами данной
    // страницы.
    final int placeholdersToReplace = math.min(
      pageItems.length,
      _items.length - _finishedItemsCount,
    );
    // Замена плэйсхолдеров.
    for (int i = 0; i < placeholdersToReplace; i++) {
      _items[i + _finishedItemsCount].value = pageItems[i];
    }
    // Добавление остальных элементов страницы.
    _addItems(
      pageItems
          .sublist(placeholdersToReplace)
          .map(ValueNotifier.new)
          .toList(growable: false),
    );
    _finishedItemsCount += pageItems.length;
    _page++;

    if (_hasPlaceholders) _loadNextPage();
  }

  /// Обрабатывает изменения констрэинтов [constraints].
  ///
  /// Провеяет и создаёт резерв скролла, если в результате изменения
  /// констрэинтов он стал составлять менее 1 вьюпорта.
  void _handleConstraintsChanged(SliverConstraints constraints) {
    _viewportCapacity = widget.gridDelegate
            .getLayout(constraints)
            .getMaxChildIndexForScrollOffset(
              widget.controller.position.viewportDimension,
            ) +
        1;
    _crossAxisCount = widget.gridDelegate
            .getLayout(constraints)
            .getMaxChildIndexForScrollOffset(1) +
        1;
    _ensureHasScrollReserve();
  }

  /// Коллбэк вызова [SliverChildBuilderDelegate.builder].
  ///
  /// Провеяет и создаёт резерв скролла, если в результате скролла он стал
  /// составлять менее 1 вьюпорта.
  void _handleItemBuildCalled(int index) {
    if (index % _crossAxisCount != 0) return;
    _ensureHasScrollReserve();
  }

  /// Провеяет и создаёт резерв скролла.
  ///
  /// Создаёт резерв скролла путём добавления плэйсхолдеров, если:
  ///  * след. страница существует;
  ///  * резерва скролла недостаточно для заполнения вьюпорта (видимой области
  /// виджета).
  /// После успешного создания резерва скролла запрашивает след. страницу, если
  /// она ещё не была запрошена.
  void _ensureHasScrollReserve() {
    // Выход, если запрос след. страница не существует.
    if (!_hasNextPage) return;

    // Кол-во вьюпортов, на заполнение которых хватает элементов.
    final double filledViewports = _items.length / _viewportCapacity;
    // Кол-во уже проскроленных вьюпортов.
    final double overscrolledViewports =
        widget.controller.offset / widget.controller.position.viewportDimension;
    // Кол-во вьюпортов, на которое хватает резерва скролла.
    final double reserveViewports = filledViewports - overscrolledViewports - 1;

    // Выход, если резерв скролла составляет более 1-го вьюпорта.
    if (reserveViewports >= 1) return;

    // Добавление плэйсхолдеров для обеспечения резерва скролла.
    final List<ValueNotifier<T?>> placeholdersToAdd = List.generate(
      ((1 - reserveViewports) * _viewportCapacity).ceil(),
      (_) => ValueNotifier(null),
    );
    _addItems(placeholdersToAdd);

    if (!_isPending) _loadNextPage();
  }

  /// Добавляет элементы [itemsToAdd] в конец списка.
  void _addItems(List<ValueNotifier<T?>> itemsToAdd) {
    _gridKey.currentState?.insertAllItems(
      _items.length,
      itemsToAdd.length,
      duration: Durations.medium1,
    );
    _items.addAll(itemsToAdd);
  }

  /// Удаляет элементы, начиная с индекса [from].
  void _removeItems({int from = 0}) {
    final CurveTween curveTween = CurveTween(curve: Easing.standardAccelerate);
    for (int i = _items.length - 1; i >= from; i--) {
      final ValueNotifier<T?> item = _items.removeAt(i)..dispose();
      _gridKey.currentState?.removeItem(
        i,
        (context, animation) => widget.itemBuilder(
          context,
          item.value,
          curveTween.animate(animation),
        ),
        duration: Durations.short4,
      );
    }
    _finishedItemsCount = math.min(_finishedItemsCount, _items.length);
  }
}
