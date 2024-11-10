import 'package:core/src/presentation/components/shimmer/shimmer_scope.dart';
import 'package:flutter/widgets.dart';

const shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1, -0.3),
  end: Alignment(1, 0.3),
  tileMode: TileMode.clamp,
);

class Shimmer extends StatelessWidget {
  const Shimmer({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    // Collect ancestor shimmer information.
    final ShimmerScopeState shimmer = ShimmerScope.of(context)!;
    return AnimatedBuilder(
      animation: shimmer.gradient,
      builder: (context, __) {
        if (!shimmer.isSized) {
          // The ancestor Shimmer widget isn't laid
          // out yet. Return an empty box.
          return const SizedBox();
        }

        final Size shimmerSize = shimmer.size;
        final Gradient gradient = shimmer.gradient.value;
        final Offset offsetWithinShimmer = shimmer.getDescendantOffset(
          descendant: context.findRenderObject()! as RenderBox,
        );

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => gradient.createShader(
            Rect.fromLTWH(
              -offsetWithinShimmer.dx,
              -offsetWithinShimmer.dy,
              shimmerSize.width,
              shimmerSize.height,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
