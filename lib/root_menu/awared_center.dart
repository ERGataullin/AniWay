import 'dart:math';

import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Располагает дочерний виджет как можно ближе к горизонтальному центру окна
/// так, чтобы при этом его не перекрывало главное меню.
class RootMenuAwaredCenter extends SingleChildRenderObjectWidget {
  const RootMenuAwaredCenter({super.key, required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRootMenuAwaredCenter(
      primaryNavigationKey: RootMenuScope.of(context).primaryNavigationKey,
      windowSize: MediaQuery.sizeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    // ignore: library_private_types_in_public_api
    _RenderRootMenuAwaredCenter renderObject,
  ) {
    renderObject.windowSize = MediaQuery.sizeOf(context);
  }
}

class _RenderRootMenuAwaredCenter extends RenderShiftedBox {
  _RenderRootMenuAwaredCenter({
    required GlobalKey primaryNavigationKey,
    required Size windowSize,
  }) : _primaryNavigationKey = primaryNavigationKey,
       _windowSize = windowSize,
       super(null);

  GlobalKey _primaryNavigationKey;
  set primaryNavigationKey(GlobalKey value) {
    if (value == _primaryNavigationKey) return;
    _primaryNavigationKey = value;
    markNeedsPaint();
  }

  Size _windowSize;
  set windowSize(Size value) {
    if (value == _windowSize) return;
    _windowSize = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    child?.layout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child != null) {
      final parentData = child.parentData! as BoxParentData;
      final primaryNavigation =
          _primaryNavigationKey.currentContext!.findRenderObject()!
              as RenderBox;

      // Смещение дочернего RenderObject как можно ближе
      // к горизонтальному центру окна.
      final double offsetX = max(
        0,
        (_windowSize.width - child.size.width) / 2 -
            primaryNavigation.size.width,
      );
      parentData.offset = Offset(offsetX, 0);
    }
    super.paint(context, offset);
  }
}
