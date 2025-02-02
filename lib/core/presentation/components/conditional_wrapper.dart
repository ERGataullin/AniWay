import 'package:flutter/material.dart';

typedef WidgetWrapper = Widget Function(BuildContext context, Widget child);

class ConditionalWrapper extends StatelessWidget {
  const ConditionalWrapper({
    super.key,
    required this.condition,
    required this.wrapper,
    required this.child,
  });

  final bool condition;

  final WidgetWrapper wrapper;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return condition ? wrapper.call(context, child) : child;
  }
}
