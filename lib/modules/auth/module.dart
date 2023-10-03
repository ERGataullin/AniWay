import 'package:flutter/widgets.dart';

class AuthModule extends StatelessWidget {
  const AuthModule({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
