import 'dart:math';

import 'package:app/root_menu/components/bottom_navigation.dart';
import 'package:app/root_menu/components/primary_navigation.dart';
import 'package:app/root_menu/components/top_navigation.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';

typedef RootMenuAwaredCenterBuilder =
    Widget Function(BuildContext context, EdgeInsets padding);

// TODO(Edgar): Избавиться к херам, перейти на SafeArea, тут баги
/// Располагает дочерний виджет как можно ближе к горизонтальному центру окна
/// так, чтобы при этом его не перекрывало главное меню.
class RootMenuAwaredCenter extends StatelessWidget {
  RootMenuAwaredCenter({
    super.key,
    this.constraints = const BoxConstraints(maxWidth: 1600),
    required Widget child,
  }) : builder = _defaultBuilder(child);

  const RootMenuAwaredCenter.builder({
    super.key,
    this.constraints = const BoxConstraints(maxWidth: 1600),
    required this.builder,
  });

  static RootMenuAwaredCenterBuilder _defaultBuilder(Widget child) {
    return (context, padding) => Padding(padding: padding, child: child);
  }

  final BoxConstraints constraints;

  final RootMenuAwaredCenterBuilder builder;

  @override
  Widget build(BuildContext context) {
    final RootMenuScope rootMenuScope = RootMenuScope.of(context);
    final RenderBox? primaryNavigation = switch (rootMenuScope
        .primaryNavigationKey
        .currentContext) {
      final BuildContext context when context.mounted =>
        context.findRenderObject() as RenderBox?,
      _ => null,
    };
    final RenderBox? topNavigation = switch (rootMenuScope
        .topNavigationKey
        .currentContext) {
      final BuildContext context when context.mounted =>
        context.findRenderObject() as RenderBox?,
      _ => null,
    };
    final RenderBox? bottomNavigation = switch (rootMenuScope
        .bottomNavigationKey
        .currentContext) {
      final BuildContext context when context.mounted =>
        context.findRenderObject() as RenderBox?,
      _ => null,
    };

    final margin = EdgeInsets.only(
      left: switch (primaryNavigation) {
        final RenderBox renderBox when renderBox.hasSize =>
          renderBox.size.width,
        _ => PrimaryNavigation.sizeFor(context).width,
      },
      top: switch (topNavigation) {
        final RenderBox renderBox when renderBox.hasSize =>
          renderBox.size.height,
        _ => TopNavigation.sizeFor(context).height,
      },
      bottom: switch (bottomNavigation) {
        final RenderBox renderBox when renderBox.hasSize =>
          renderBox.size.height,
        _ => BottomNavigation.sizeFor(context).height,
      },
    );

    final Size windowSize = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final BoxConstraints effectiveConstraints = constraints.enforce(
          this.constraints,
        );

        final double paddingHorizontal =
            windowSize.width - effectiveConstraints.maxWidth;
        final double paddingLeft = max(0, paddingHorizontal / 2 - margin.left);
        final double paddingRight = max(
          0,
          paddingHorizontal - paddingLeft - margin.horizontal,
        );
        final double paddingVertical =
            windowSize.height - effectiveConstraints.maxHeight;
        final double paddingTop = max(0, paddingVertical / 2 - margin.top);
        final double paddingBottom = max(
          0,
          paddingVertical - paddingTop - margin.vertical,
        );
        final padding = EdgeInsets.fromLTRB(
          paddingLeft,
          paddingTop,
          paddingRight,
          paddingBottom,
        );

        return builder(context, padding);
      },
    );
  }
}
