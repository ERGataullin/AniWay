import 'package:auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/movies.dart';
import 'package:player/player.dart';
import 'package:root_menu/root_menu.dart';

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

class AppRouter implements RouterConfig<RouteMatchList> {
  AppRouter({
    required ThemeData videoPlayerTheme,
  }) : _videoPlayerTheme = videoPlayerTheme;

  final ThemeData _videoPlayerTheme;

  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey();

  final Uri _rootUri = Uri(path: '/');

  final Uri _signInUri = Uri(path: 'sign-in');

  final Uri _movieUri = Uri(path: ':movieId');

  final Uri _watchNowUri = Uri();

  final Uri _searchUri = Uri(path: 'search');

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: kIsWeb ? _watchNowUri.locate() : _signInUri.locate(),
    routes: [
      _buildSignInRoute(baseUri: _rootUri),
      _buildMenuRoute(baseUri: _rootUri),
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

  GoRoute _buildSignInRoute({
    Uri? baseUri,
  }) {
    final Uri uri = baseUri?.resolveUri(_signInUri) ?? _signInUri;

    return GoRoute(
      path: uri.path,
      builder: (context, state) => SignInWidget(
        onSignedIn: () => context.go(_watchNowUri.locate()),
      ),
    );
  }

  ShellRouteBase _buildMenuRoute({
    Uri? baseUri,
  }) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => RootMenuWidget(
        key: UniqueKey(),
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          MenuDestinationData.watchNow,
          MenuDestinationData.search,
          MenuDestinationData.store,
          MenuDestinationData.library,
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
            _buildWatchNowRoute(baseUri: baseUri),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _buildSearchRoute(baseUri: baseUri),
          ],
        ),
      ],
    );
  }

  GoRoute _buildWatchNowRoute({
    Uri? baseUri,
  }) {
    final Uri uri = baseUri?.resolveUri(_watchNowUri) ?? _watchNowUri;

    final GoRoute movieRoute = _buildMovieRoute(
      baseUri: Uri(path: 'movies/'),
    );

    return GoRoute(
      path: uri.path,
      routes: [
        movieRoute,
      ],
      builder: (context, state) => WatchNowWidget(
        playerBuilder: (movieId, episodeId) => Theme(
          data: _videoPlayerTheme,
          child: MoviePlayerWidget(
            movieId: movieId,
            episodeId: episodeId,
          ),
        ),
        onMoviePressed: (id) => context.go(
          state.uri.resolveUri(Uri(path: movieRoute.path)).locate(
            pathParameters: {
              'movieId': id,
            },
          ),
        ),
      ),
    );
  }

  GoRoute _buildMovieRoute({
    Uri? baseUri,
  }) {
    final Uri uri = baseUri?.resolveUri(_movieUri) ?? _movieUri;

    return GoRoute(
      path: uri.path,
      builder: (context, state) => const MovieWidget(),
    );
  }

  GoRoute _buildSearchRoute({
    Uri? baseUri,
  }) {
    final Uri uri = baseUri?.resolveUri(_searchUri) ?? _searchUri;

    final GoRoute movieRoute = _buildMovieRoute(
      baseUri: Uri(path: 'movies/'),
    );

    return GoRoute(
      path: uri.path,
      routes: [
        movieRoute,
      ],
      builder: (context, state) => SearchWidget(
        onMoviePressed: (id) => context.go(
          state.uri.resolveUri(Uri(path: movieRoute.path)).locate(
            pathParameters: {
              'movieId': id,
            },
          ),
        ),
      ),
    );
  }
}
