import 'dart:math';

import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    this.extendBodyBehindAppBar = false,
    this.constraints = const BoxConstraints(maxWidth: 1600),
    this.appBar,
    this.body,
  });

  final bool extendBodyBehindAppBar;

  final BoxConstraints constraints;

  final PreferredSizeWidget? appBar;

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: RootMenu.hasTopNavigation(context) ? null : appBar,
      body: _WindowTopCentered(constraints: constraints, child: body),
    );
  }
}

class _WindowTopCentered extends SingleChildRenderObjectWidget {
  const _WindowTopCentered({
    this.constraints = const BoxConstraints(),
    required super.child,
  });

  final BoxConstraints constraints;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWindowTopCentered(
      windowSize: MediaQuery.sizeOf(context),
      childConstraints: constraints,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    // ignore: library_private_types_in_public_api
    _RenderWindowTopCentered renderObject,
  ) {
    renderObject
      ..windowSize = MediaQuery.sizeOf(context)
      ..childConstraints = constraints;
  }
}

class _RenderWindowTopCentered extends RenderShiftedBox {
  _RenderWindowTopCentered({
    required Size windowSize,
    BoxConstraints childConstraints = const BoxConstraints(),
  }) : _windowSize = windowSize,
       _childConstraints = childConstraints,
       super(null);

  @override
  bool get sizedByParent => true;

  var _isFirstFrame = true;

  Offset _globalOffset = Offset.zero;

  Size _windowSize;
  set windowSize(Size value) {
    if (value == _windowSize) return;
    _windowSize = value;
    markNeedsLayout();
  }

  BoxConstraints _childConstraints;
  set childConstraints(BoxConstraints value) {
    if (value == _childConstraints) return;
    _childConstraints = value;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) return;
    child.layout(constraints.enforce(_childConstraints), parentUsesSize: true);

    if (_isFirstFrame) return;

    Offset globalOffset = Offset.zero;
    RenderObject node = this;
    while (node.parent != null) {
      if (node.parentData!.runtimeType != ParentData) {
        globalOffset += (node.parentData! as BoxParentData).offset;
      }
      node = node.parent!;
    }
    _globalOffset = globalOffset;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child != null) {
      final childParentData = child.parentData as BoxParentData?;
      if (_isFirstFrame) _globalOffset = localToGlobal(Offset.zero);
      final double offsetX = max(
        0,
        (_windowSize.width - child.size.width) / 2 - _globalOffset.dx,
      );
      childParentData!.offset = Offset(offsetX, childParentData.offset.dy);
    }

    super.paint(context, offset);

    _isFirstFrame = false;
  }
}
