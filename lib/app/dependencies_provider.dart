import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/error_handler.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.overrides = const {},
    required this.child,
  });

  final Set<Provider<dynamic>> overrides;
  final Widget child;

  Provider<ErrorHandler> get _errorHandler => Provider(
        create: (context) => AppErrorHandler(),
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        _errorHandler,
        ...overrides,
      ],
      child: child,
    );
  }
}
