import 'package:flutter/material.dart';

class PlatformWrapper extends StatelessWidget {
  const PlatformWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
