import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '/app/models/route_definition.dart';
import '/modules/auth/features/sign_in/widget.dart';
import '/modules/auth/module.dart';

extension _RouteLocator on RouteDefinition {
  String locate({
    Map<String, dynamic> pathParameters = const {},
  }) {
    final StringBuffer buffer = StringBuffer();

    final Iterable<String> pathSegments = uri.pathSegments.map(
      (pathSegment) => pathSegment.startsWith(':')
          ? pathParameters[pathSegment.substring(1)]!.toString()
          : pathSegment,
    );
    buffer.writeAll(pathSegments, '/');

    return buffer.toString();
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
  }) : signIn = RouteDefinition.parse(signIn);

  final RouteDefinition signIn;

  List<RouteBase> call({
    required VoidCallback onSignedIn,
  }) =>
      [
        GoRoute(
          path: signIn.path,
          builder: (context, state) => SignInWidget(
            onSignedIn: () {},
          ),
        ),
      ];
}
