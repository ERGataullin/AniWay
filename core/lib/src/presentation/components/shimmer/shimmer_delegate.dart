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
  ) builder;

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
  const DecoratedBoxShimmerDelegate({
    this.decoration = const BoxDecoration(),
  });

  final BoxDecoration decoration;

  @override
  Widget build(
    BuildContext context,
    Color? color,
    Gradient? gradient,
    Widget? child,
  ) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: decoration.copyWith(
        color: color,
        gradient: gradient,
      ),
      child: child,
    );
  }
}
