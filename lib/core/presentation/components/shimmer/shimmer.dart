import 'package:app/core/core.dart';
import 'package:flutter/material.dart';

typedef ShimmerBuilder =
    Widget Function(BuildContext context, Gradient? gradient, Widget? child);

class Shimmer extends StatelessWidget {
  const Shimmer({
    super.key,
    this.enabled = true,
    this.constraints,
    this.delegate = const DecoratedBoxShimmerDelegate(),
    this.child,
  });

  final bool enabled;

  final BoxConstraints? constraints;

  final ShimmerDelegate delegate;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return delegate.build(context, null, null, child);
    final ShimmerScopeState shimmerScope = ShimmerScope.of(context);
    return ConditionalWrapper(
      condition: enabled && constraints != null,
      wrapper: (context, child) =>
          ConstrainedBox(constraints: constraints!, child: child),
      child: AnimatedBuilder(
        animation: shimmerScope.animation,
        builder: (_, _) {
          final renderBox = context.findRenderObject() as RenderBox?;
          final (Color? color, Gradient? gradient) = shimmerScope
              .createBackground(
                colorScheme: ColorScheme.of(context),
                shimmer: renderBox,
              );
          return delegate.build(context, color, gradient, child);
        },
      ),
    );
  }
}
