import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_arch/flutter_feature_arch.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/modules/auth/module.dart';
import '/app_error_handler.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.overrides = const {},
    required this.child,
  });

  final Set<Provider> overrides;
  final Widget child;

  Provider<ErrorHandler> get _errorHandler => Provider<ErrorHandler>(
        create: (context) => AppErrorHandler(),
      );

  MultiProvider get _modules => MultiProvider(
        providers: [
          Provider<AuthModule>(
            create: (context) => AuthModule(
              onSignedIn: () => print('Signed in'),
            ),
          ),
          Provider<Set<Module<RouteBase>>>(
            create: (context) => {
              context.read<AuthModule>(),
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        _errorHandler,
        _modules,
        ...overrides,
      ],
      child: child,
    );
  }
}
