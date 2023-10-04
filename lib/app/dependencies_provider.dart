import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/error_handle/debug_print.dart';
import '/app/domain/services/error_handle/service.dart';
import '/app/domain/services/network/http.dart';
import '/app/domain/services/network/service.dart';

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({
    super.key,
    this.overrides = const {},
    required this.child,
  });

  final Set<Provider<dynamic>> overrides;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ErrorHandleService>(
          create: (context) => DebugPrintErrorHandleService(),
        ),
        Provider<NetworkService>(
          create: (context) => HttpNetworkService(
            baseUrl: 'https://anime365.ru',
          ),
        ),
        ...overrides,
      ],
      child: child,
    );
  }
}
