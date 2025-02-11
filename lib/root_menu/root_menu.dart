import 'package:app/root_menu/components/bottom_navigation.dart';
import 'package:app/root_menu/components/primary_navigation.dart';
import 'package:app/root_menu/components/top_navigation.dart';
import 'package:flutter/widgets.dart';

abstract class RootMenu {
  static bool hasPrimaryNavigation(BuildContext context) =>
      PrimaryNavigation.breakpoint.isActive(context);

  static bool hasTopNavigation(BuildContext context) =>
      TopNavigation.breakpoint.isActive(context);

  static bool hasBottomNavigation(BuildContext context) =>
      BottomNavigation.breakpoint.isActive(context);
}
