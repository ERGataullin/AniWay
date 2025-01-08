import 'package:core/core.dart' show Shimmer;
import 'package:core/src/presentation/components/shimmer/scope_animation_controller.dart';
import 'package:flutter/material.dart';

class ShimmerScope extends StatefulWidget {
  const ShimmerScope({
    super.key,
    required this.child,
  });

  static ShimmerScopeState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShimmerScopeInheritedState>()!
        .state;
  }

  final Widget child;

  @override
  ShimmerScopeState createState() => ShimmerScopeState();
}

class ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final ShimmerScopeAnimationController _animationController =
      ShimmerScopeAnimationController(
    value: -0.5,
    vsync: this,
  );

  Animation<double> get animation => _animationController;

  (Color?, LinearGradient?) createBackground({
    required ColorScheme colorScheme,
    RenderBox? shimmer,
  }) {
    final scope = context.findRenderObject() as RenderBox?;
    final Color backgroundColor = colorScheme.surfaceContainerLow;

    final bool attachedShimmer = shimmer?.attached ?? false;
    final bool attachedScope = scope?.attached ?? false;
    if (!attachedShimmer || !attachedScope) return (backgroundColor, null);

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.1, 0.3, 0.4],
      colors: [
        colorScheme.surfaceContainerLow,
        colorScheme.surfaceContainerHighest,
        colorScheme.surfaceContainerLow,
      ],
      transform: _SlidingGradientTransform(
        slidePercent: _animationController.value,
        scopeSize: scope!.size,
        shimmerOffset: shimmer!.localToGlobal(Offset.zero, ancestor: scope),
      ),
    );
    return (null, gradient);
  }

  @override
  void initState() {
    super.initState();
    _animationController.hasClients.addListener(_handleHasClientsChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScopeInheritedState(
      state: this,
      child: widget.child,
    );
  }

  void _handleHasClientsChanged() {
    if (_animationController.hasClients.value) {
      _animationController.repeat(
        min: -0.5,
        max: 1.5,
        period: Durations.extralong4,
      );
    } else {
      _animationController.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_animationController.hasClients.value) {
          _animationController.reset();
        }
      });
    }
  }
}

class _ShimmerScopeInheritedState extends InheritedWidget {
  const _ShimmerScopeInheritedState({
    required this.state,
    required super.child,
  });

  final ShimmerScopeState state;

  @override
  bool updateShouldNotify(covariant _ShimmerScopeInheritedState oldWidget) {
    return state != oldWidget.state;
  }
}

/// Трансформация градиента шиммера [Shimmer], устанавливающая размер градиента
/// равным размеру скоупа [ShimmerScope] и начало координат равным положению
/// шиммера [Shimmer] внутри скоупа [ShimmerScope].
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
    required this.scopeSize,
    this.shimmerOffset = Offset.zero,
  });

  /// Процент прогресса слайда в границах скоупа [ShimmerScope].
  ///
  /// Например, если скоуп [ShimmerScope] занимает всю страницу, то
  /// значение [slidePercent] `0.5` означает, что слайд прошёл
  /// половину страницы по оси X, и его начало находится в центре страницы.
  final double slidePercent;

  /// Размер скоупа [ShimmerScope].
  final Size scopeSize;

  /// Положение шиммера [Shimmer] в системе координат, началом которой является
  /// точка начала скоупа [ShimmerScope].
  final Offset shimmerOffset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double widthMultiplier = scopeSize.width / bounds.width;
    final double heightMultiplier = scopeSize.height / bounds.bottom;
    return Matrix4.zero()
      ..setIdentity()
      // Увеличиваем градиент с размеров шиммера
      // до размеров скоупа, чтобы иметь единый градиент на весь скоуп.
      ..scale(
        widthMultiplier,
        heightMultiplier,
        0,
      )
      // Смещаем начало координат так, чтобы им стала позиция шиммера с учётом
      // прогресса слайда.
      ..setTranslationRaw(
        -shimmerOffset.dx -
            bounds.left * (widthMultiplier - 1) +
            slidePercent * scopeSize.width,
        -shimmerOffset.dy - bounds.top * (heightMultiplier - 1),
        0,
      );
  }
}
