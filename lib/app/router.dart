import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '/modules/auth/presentation/sign_in/widget.dart';
import '/modules/movies/presentation/watch_now/widget.dart';

extension _RouteLocator on Uri {
  String locate({
    Map<String, dynamic> pathParameters = const {},
  }) {
    return replace(
      path: pathSegments.isEmpty ? '/' : null,
      pathSegments: pathSegments.isEmpty
          ? null
          : [
              '',
              ...pathSegments.map(
                (pathSegment) => pathSegment.startsWith(':')
                    ? pathParameters[pathSegment.substring(1)]!.toString()
                    : pathSegment,
              ),
            ],
    ).toString();
  }
}

class AppRouter implements RouterConfig<RouteMatchList> {
  final Uri _signInUri = Uri.parse('/sign-in');
  final Uri _watchNowUri = Uri.parse('/');

  late final GoRouter _goRouter = GoRouter(
    initialLocation: _watchNowUri.locate(),
    routes: [
      ..._authRoutes,
      ..._moviesRoutes,
    ],
  );

  late final List<RouteBase> _authRoutes = [
    GoRoute(
      path: _signInUri.path,
      builder: (context, state) => SignInWidget(
        onSignedIn: () => context.pushReplacement(_watchNowUri.locate()),
      ),
    ),
  ];

  late final List<RouteBase> _moviesRoutes = [
    GoRoute(
      path: _watchNowUri.path,
      builder: (context, state) => WatchNowWidget(
        onUpNextPressed: (movieId, episodeId) {},
        onMoviePressed: (id) {},
      ),
    ),
  ];

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
