import 'package:auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:movies/movies.dart';
import 'package:root_menu/root_menu.dart';

class AppRouter implements RouterConfig<RouteMatchList> {
  AppRouter({
    required L10n l10n,
    required ValueListenable<bool> signedIn,
  })  : _l10n = l10n,
        _signedIn = signedIn;

  final L10n _l10n;

  final ValueListenable<bool> _signedIn;

  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey();

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: _signedIn,
    routes: [
      _buildSignIn(),
      _buildRootMenu(),
    ],
    redirect: (context, state) {
      return _signedIn.value && state.topRoute!.name == _Routes.signIn
          ? state.namedLocation(_Routes.home)
          : !_signedIn.value
              ? state.namedLocation(_Routes.signIn)
              : null;
    },
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

  GoRoute _buildSignIn() {
    return GoRoute(
      name: _Routes.signIn,
      path: '/sign-in',
      builder: (context, state) => const SignInWidget(),
    );
  }

  ShellRouteBase _buildRootMenu() {
    return StatefulShellRoute.indexedStack(
      branches: [
        StatefulShellBranch(
          routes: [
            _buildHome(),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _buildSearch(),
          ],
        ),
      ],
      builder: (context, state, navigationShell) => RootMenu(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
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
        child: navigationShell,
      ),
    );
  }

  GoRoute _buildHome() {
    final GoRoute movieRoute = _buildMovie(parent: _Routes.home);
    return GoRoute(
      name: _Routes.home,
      path: '/',
      routes: [movieRoute],
      builder: (context, state) => HomeWidget(
        onMoviePressed: (id) => context.goNamed(
          movieRoute.name!,
          pathParameters: {'movieId': id.toString()},
        ),
      ),
    );
  }

  GoRoute _buildMovie({required String parent}) {
    return GoRoute(
      name: _Routes.movie(parent: parent),
      path: 'movies/:movieId',
      builder: (context, state) => const MovieWidget(),
    );
  }

  GoRoute _buildSearch() {
    final GoRoute movieRoute = _buildMovie(parent: _Routes.search);
    return GoRoute(
      name: _Routes.search,
      path: '/search',
      routes: [movieRoute],
      builder: (context, state) => SearchWidget(
        onMoviePressed: (id) => context.goNamed(
          movieRoute.name!,
          pathParameters: {'movieId': id.toString()},
        ),
      ),
    );
  }
}

class _Routes {
  const _Routes._();

  static const String signIn = 'sign-in';

  static const String home = 'home';

  static const String search = 'search';

  static String movie({required String parent}) => '$parent/movies/:movieId';
}
