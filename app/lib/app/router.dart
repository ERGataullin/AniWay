import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '/modules/auth/presentation/sign_in/widget.dart';
import '/modules/menu/presentation/menu/widget.dart';
import '/modules/movies/presentation/movie/widget.dart';
import '/modules/movies/presentation/watch_now/widget.dart';

extension _RouteLocating on Uri {
  Uri locateUri({
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
    );
  }

  String locate({
    Map<String, dynamic> pathParameters = const {},
  }) {
    return locateUri(pathParameters: pathParameters).toString();
  }
}

extension _RouteMerging on Uri {
  bool get _isPortDefault =>
      scheme == 'http' && port == 80 ||
      scheme == 'https' && port == 443 ||
      port == 0;

  Uri merge(Uri uri) {
    return Uri(
      scheme: scheme.isEmpty ? uri.scheme : scheme,
      userInfo: userInfo.isEmpty ? uri.userInfo : userInfo,
      host: host.isEmpty ? uri.host : host,
      port: switch ((_isPortDefault, uri._isPortDefault)) {
        (false, false) => uri.port,
        (false, true) => port,
        (true, false) => uri.port,
        (true, true) => null,
      },
      pathSegments: [
        ...pathSegments,
        ...uri.pathSegments,
      ],
      queryParameters: queryParameters.isEmpty && uri.queryParameters.isEmpty
          ? null
          : {
              ...queryParameters,
              ...uri.queryParameters,
            },
      fragment: switch ((fragment.isEmpty, uri.fragment.isEmpty)) {
        (false, false) => uri.fragment,
        (false, true) => fragment,
        (true, false) => uri.fragment,
        (true, true) => null,
      },
    );
  }
}

class AppRouter implements RouterConfig<RouteMatchList> {
  final Uri _signInUri = Uri(path: '/sign-in');

  final Uri _movieUri = Uri(path: 'movies/:id');

  final Uri _watchNowUri = Uri(path: '/');

  late final GoRouter _goRouter = GoRouter(
    initialLocation: kIsWeb ? _watchNowUri.locate() : _signInUri.locate(),
    routes: [
      _buildSignInRoute(),
      _buildMenuRoute(),
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

  RouteBase _buildSignInRoute() => GoRoute(
        path: _signInUri.path,
        builder: (context, state) => SignInWidget(
          onSignedIn: () => context.go(_watchNowUri.locate()),
        ),
      );

  RouteBase _buildMenuRoute() => StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MenuWidget(
          key: UniqueKey(),
          selectedIndex: navigationShell.currentIndex,
          destinations: const [
            MenuDestinationData.watchNow,
            MenuDestinationData.store,
            MenuDestinationData.library,
            MenuDestinationData.search,
          ],
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          child: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              _buildWatchNowRoute(),
            ],
          ),
        ],
      );

  RouteBase _buildMovieRoute() => GoRoute(
        path: _movieUri.path,
        builder: (context, state) => const MovieWidget(),
      );

  RouteBase _buildWatchNowRoute() => GoRoute(
        path: _watchNowUri.path,
        routes: [
          _buildMovieRoute(),
        ],
        builder: (context, state) => WatchNowWidget(
          onUpNextPressed: (movieId, episodeId) {},
          onMoviePressed: (id) => context.go(
            state.uri.merge(_movieUri).locate(
              pathParameters: {'id': id},
            ),
          ),
        ),
      );
}
