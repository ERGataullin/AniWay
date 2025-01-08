import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(
        'A',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Alvida',
          package: 'core',
          height: .75,
          color: ColorScheme.of(context).primary,
        ),
      ),
    );
  }
}
