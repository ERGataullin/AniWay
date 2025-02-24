import 'package:flutter/material.dart';

class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    this.constraints = const BoxConstraints(maxWidth: 1600),
    this.child,
  });

  final BoxConstraints constraints;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(constraints: constraints, child: child);
  }
}
