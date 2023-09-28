import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_arch/flutter_feature_arch.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '/app_error_handler.dart';
import '/modules/auth/module.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.overrides = const <Provider<dynamic>>{},
    required this.child,
  });

  final Set<Provider<dynamic>> overrides;
  final Widget child;

  Provider<ErrorHandler> get _errorHandler => Provider<ErrorHandler>(
        create: (BuildContext context) => AppErrorHandler(),
      );

  MultiProvider get _modules => MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AuthModule>(
            create: (BuildContext context) => AuthModule(
              onSignedIn: () => debugPrint('Signed in'),
            ),
          ),
          Provider<Set<Module<RouteBase>>>(
            create: (BuildContext context) => <Module<RouteBase>>{
              context.read<AuthModule>(),
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        _errorHandler,
        _modules,
        ...overrides,
      ],
      child: child,
    );
  }
}
