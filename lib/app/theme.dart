import 'package:flutter/material.dart';

extension _AppOverrides on ThemeData {
  ThemeData get appOverrides => copyWith(
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
}

class AppTheme {
  AppTheme({
    ThemeData? light,
    ThemeData? dark,
  })  : light = light ?? ThemeData.light(useMaterial3: true).appOverrides,
        dark = dark ?? ThemeData.dark(useMaterial3: true).appOverrides;

  final ThemeData light;

  final ThemeData dark;
}
