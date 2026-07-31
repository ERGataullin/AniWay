import 'dart:math';

import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Располагает дочерний виджет как можно ближе к горизонтальному центру окна
/// так, чтобы при этом его не перекрывало главное меню.
class RootMenuAwaredCenter extends SingleChildRenderObjectWidget {
  const RootMenuAwaredCenter({
    super.key,
    this.constraints = const BoxConstraints(maxWidth: 1600),
    required Widget super.child,
  });

  final BoxConstraints constraints;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRootMenuAwaredCenter(
      primaryNavigationKey: RootMenuScope.of(context).primaryNavigationKey,
      windowSize: MediaQuery.sizeOf(context),
      childConstraints: constraints,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    // ignore: library_private_types_in_public_api
    _RenderRootMenuAwaredCenter renderObject,
  ) {
    renderObject
      ..windowSize = MediaQuery.sizeOf(context)
      ..childConstraints = constraints;
  }
}

class _RenderRootMenuAwaredCenter extends RenderShiftedBox {
  _RenderRootMenuAwaredCenter({
    required this._primaryNavigationKey,
    required this._windowSize,
    required this._childConstraints,
  }) : super(null);

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

  BoxConstraints _childConstraints;
  set childConstraints(BoxConstraints value) {
    if (value == _childConstraints) return;
    _childConstraints = value;
    markNeedsLayout();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    child?.layout(constraints.enforce(_childConstraints));
  }

  @override
  Rect describeApproximatePaintClip(covariant RenderBox child) {
    final Offset childOffset = (child.parentData! as BoxParentData).offset;
    return child.paintBounds.translate(childOffset.dx, childOffset.dy);
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
    context.pushClipRect(
      needsCompositing,
      offset,
      describeApproximatePaintClip(child!),
      super.paint,
    );
  }
}
