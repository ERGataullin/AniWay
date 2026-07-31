import 'package:flutter/widgets.dart';

abstract class ShimmerDelegate {
  const ShimmerDelegate();

  Widget build(
    BuildContext context,
    Color? color,
    Gradient? gradient,
    Widget? child,
  );
}

class CustomShimmerDelegate implements ShimmerDelegate {
  const CustomShimmerDelegate(this.builder);

  final Widget Function(
    BuildContext context,
    Color? color,
    Gradient? gradient,
    Widget? child,
  )
  builder;

  @override
  Widget build(
    BuildContext context,
    Color? color,
    Gradient? gradient,
    Widget? child,
  ) {
    return builder(context, color, gradient, child);
  }
}

class DecoratedBoxShimmerDelegate implements ShimmerDelegate {
  const DecoratedBoxShimmerDelegate({this.decoration = const BoxDecoration()})
    : assert(decoration is BoxDecoration || decoration is ShapeDecoration);

  final Decoration decoration;

  @override
  Widget build(
    BuildContext context,
    Color? color,
    Gradient? gradient,
    Widget? child,
  ) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: switch (decoration) {
        final BoxDecoration boxDecoration => boxDecoration.copyWith(
          color: color,
          gradient: gradient,
        ),
        final ShapeDecoration shapeDecoration => ShapeDecoration(
          color: color,
          gradient: gradient,
          image: shapeDecoration.image,
          shadows: shapeDecoration.shadows,
          shape: shapeDecoration.shape,
        ),
        _ => throw UnimplementedError(
          'tried using a $DecoratedBoxShimmerDelegate with '
          'an unsupported decoration type',
        ),
      },
      child: child,
    );
  }
}
