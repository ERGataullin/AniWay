import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

extension Adaptive on BuildContext {
  Breakpoint get breakpoint => Breakpoint.activeBreakpointOf(this);

  double get margin => breakpoint.margin;

  EdgeInsets get marginAll => EdgeInsets.all(margin);

  EdgeInsets get marginHorizontal => EdgeInsets.symmetric(horizontal: margin);

  EdgeInsets get marginVertical => EdgeInsets.symmetric(vertical: margin);

  double get padding => breakpoint.padding;
}
