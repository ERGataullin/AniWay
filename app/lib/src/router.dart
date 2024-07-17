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
      _buildMoviePlayer(),
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

  GoRoute _buildMoviePlayer() {
    return GoRoute(
      name: _Routes.moviePlayer,
      path: '/movies/:movieId/player',
      pageBuilder: (context, state) => MaterialPage(
        fullscreenDialog: true,
        child: MoviePlayerWidget(
          movieId: int.parse(state.pathParameters['movieId']!),
          initialEpisodeId: switch (state.uri.queryParameters['episodeId']) {
            final String episodeIdQuery => int.tryParse(episodeIdQuery),
            _ => null,
          },
        ),
      ),
    );
  }

  GoRoute _buildHome() {
    return GoRoute(
      name: _Routes.home,
      path: '/',
      routes: [
        _buildUpNext(),
        _buildMovie(parent: _Routes.home),
      ],
      builder: (context, state) => HomeWidget(
        upNextUri: Uri.parse(state.namedLocation(_Routes.upNext)),
        onUpNextPressed: (movieId, episodeId) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': movieId.toString()},
          queryParameters: {'episodeId': episodeId.toString()},
        ),
        popularUri: Uri.parse(state.namedLocation(_Routes.search)),
        onMoviePressed: (id) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': id.toString()},
        ),
      ),
    );
  }

  GoRoute _buildSearch() {
    final GoRoute movieRoute = _buildMovie(parent: _Routes.search);
    return GoRoute(
      name: _Routes.search,
      path: '/search',
      routes: [movieRoute],
      builder: (context, state) => MoviesSearchWidget(
        onMoviePressed: (id) => context.pushNamed(
          _Routes.moviePlayer,
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

  GoRoute _buildUpNext() {
    final GoRoute movieRoute = _buildMovie(parent: _Routes.upNext);
    return GoRoute(
      name: _Routes.upNext,
      path: 'up-next',
      routes: [movieRoute],
      builder: (context, state) => UpNextWidget(
        onItemPressed: (movieId, episodeId) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': movieId.toString()},
          queryParameters: {'episodeId': episodeId.toString()},
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

  static const String moviePlayer = 'movie-player';

  static const String upNext = 'up-next';

  static String movie({required String parent}) => '$parent/movies/:movieId';
}
