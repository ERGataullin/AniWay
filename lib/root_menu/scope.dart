import 'package:app/root_menu/components/top_navigation.dart';
import 'package:flutter/widgets.dart';

/// Информация о главном меню, которая может быть необходима во вне.
class RootMenuScope extends InheritedWidget {
  const RootMenuScope({
    super.key,
    required this.primaryNavigationKey,
    required this.topNavigationKey,
    required this.bottomNavigationKey,
    required super.child,
  });

  final GlobalKey primaryNavigationKey;

  final GlobalKey topNavigationKey;

  final GlobalKey bottomNavigationKey;

  bool get hasTopNavigation =>
      !TopNavigation.sizeFor(topNavigationKey.currentContext!).isEmpty;

  static RootMenuScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RootMenuScope>()!;
  }

  @override
  bool updateShouldNotify(RootMenuScope oldWidget) {
    return primaryNavigationKey != oldWidget.primaryNavigationKey ||
        topNavigationKey != oldWidget.topNavigationKey ||
        bottomNavigationKey != oldWidget.bottomNavigationKey;
  }
}
