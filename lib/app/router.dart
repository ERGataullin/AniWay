import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '/app/domain/models/route_definition.dart';
import '/modules/auth/module.dart';
import '/modules/auth/presentation/sign_in/widget.dart';

extension _RouteLocator on RouteDefinitionData {
  String locate({
    Map<String, dynamic> pathParameters = const {},
  }) {
    return uri.replace(
      pathSegments: [
        '',
        ...uri.pathSegments.map(
          (pathSegment) => pathSegment.startsWith(':')
              ? pathParameters[pathSegment.substring(1)]!.toString()
              : pathSegment,
        ),
      ],
    ).toString();
  }
}

class AppRouter implements RouterConfig<RouteMatchList> {
  final _AuthRoutes _authRoutes = _AuthRoutes(
    signIn: '/sign-in',
  );

  late final GoRouter _goRouter = GoRouter(
    initialLocation: _authRoutes.signIn.locate(),
    routes: [
      ShellRoute(
        routes: _authRoutes(
          onSignedIn: () {},
        ),
        builder: (context, state, child) => AuthModule(child: child),
      ),
    ],
  );

  @override
  BackButtonDispatcher? get backButtonDispatcher =>
      _goRouter.backButtonDispatcher;

  @override
  RouteInformationParser<RouteMatchList>? get routeInformationParser =>
      _goRouter.routeInformationParser;

  @override
  RouteInformationProvider? get routeInformationProvider =>
      _goRouter.routeInformationProvider;

  @override
  RouterDelegate<RouteMatchList> get routerDelegate => _goRouter.routerDelegate;
}

class _AuthRoutes {
  _AuthRoutes({
    required String signIn,
  }) : signIn = RouteDefinitionData.parse(signIn);

  final RouteDefinitionData signIn;

  List<RouteBase> call({
    required VoidCallback onSignedIn,
  }) =>
      [
        GoRoute(
          path: signIn.path,
          builder: (context, state) => const SignInWidget(),
        ),
      ];
}
