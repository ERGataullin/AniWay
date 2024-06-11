import 'package:auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
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
    required L10n l10n,
    required ThemeData videoPlayerTheme,
    required ValueListenable<bool> signedIn,
  })  : _l10n = l10n,
        _videoPlayerTheme = videoPlayerTheme,
        _signedIn = signedIn;

  final L10n _l10n;

  final ThemeData _videoPlayerTheme;

  final ValueListenable<bool> _signedIn;

  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey();

  final Uri _rootUri = Uri(path: '/');

  final Uri _signInUri = Uri(path: 'sign-in');

  final Uri _movieUri = Uri(path: ':movieId');

  final Uri _homeUri = Uri();

  final Uri _searchUri = Uri(path: 'search');

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _homeUri.locate(),
    refreshListenable: _signedIn,
    redirect: (context, state) {
      final Uri signInUri = _rootUri.resolveUri(_signInUri);
      if (!_signedIn.value && state.uri != signInUri) {
        return signInUri.locate();
      }

      return null;
    },
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
        onSignedIn: () => context.go(_homeUri.locate()),
      ),
    );
  }

  ShellRouteBase _buildMenuRoute({
    Uri? baseUri,
  }) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => RootMenu(
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: _l10n.homePageTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: _l10n.searchPageTitle,
          ),
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
            _buildHomeRoute(baseUri: baseUri),
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

  GoRoute _buildHomeRoute({
    Uri? baseUri,
  }) {
    final Uri uri = baseUri?.resolveUri(_homeUri) ?? _homeUri;

    final GoRoute movieRoute = _buildMovieRoute(
      baseUri: Uri(path: 'movies/'),
    );

    return GoRoute(
      path: uri.path,
      routes: [
        movieRoute,
      ],
      builder: (context, state) => HomeWidget(
        playerBuilder: (child) => Theme(
          data: _videoPlayerTheme,
          child: child,
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
          state.uri
              .resolveUri(Uri(path: '${uri.path}/${movieRoute.path}'))
              .locate(
            pathParameters: {
              'movieId': id,
            },
          ),
        ),
      ),
    );
  }
}
