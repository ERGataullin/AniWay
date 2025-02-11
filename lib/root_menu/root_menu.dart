import 'package:app/root_menu/components/top_navigation.dart';
import 'package:flutter/widgets.dart';

abstract class RootMenu {
  static bool hasTopNavigation(BuildContext context) =>
      TopNavigation.breakpoint.isActive(context);
}
