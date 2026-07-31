import 'package:app/auth/auth.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/presentation/components/movie_player/widget.dart';
import 'package:app/movies/presentation/episodes/widget.dart';
import 'package:app/movies/presentation/home/widget.dart';
import 'package:app/movies/presentation/library/widget.dart';
import 'package:app/movies/presentation/movie/widget.dart';
import 'package:app/movies/presentation/search/widget.dart';
import 'package:app/movies/presentation/up_next/widget.dart';
import 'package:app/root_menu/container.dart';
import 'package:app/root_menu/destination.dart';
import 'package:app/root_menu/view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter implements RouterConfig<RouteMatchList> {
  AppRouter({required this._signedIn}) {
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  final ValueListenable<bool> _signedIn;

  late final _goRouter = GoRouter(
    refreshListenable: _signedIn,
    routes: [
      _RoutesBuilders.buildSignIn(),
      _RoutesBuilders.buildMoviePlayer(),
      _RoutesBuilders.buildRootMenu(),
    ],
    redirect: (context, state) {
      const referrerKey = 'referrer';
      final String? route = state.topRoute?.name;
      return switch (_signedIn.value) {
        false when route != _Routes.signIn => state.namedLocation(
          _Routes.signIn,
          queryParameters: {referrerKey: state.matchedLocation},
        ),
        false => null,
        true when route == _Routes.signIn =>
          state.uri.queryParameters[referrerKey] ??
              state.namedLocation(_Routes.home),
        true => null,
      };
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
}

abstract class _Routes {
  static const signIn = '/sign-in';

  static const home = '/home';

  static const moviePlayer = '/movie-player';

  static const upNext = '/up-next';

  static const library = '/library';

  static String search({String? parent}) =>
      parent == null ? '/search' : '$parent/search';

  static String movie({required String parent}) => '$parent/movies/:movieId';

  static String episodes({String? parent}) => '$parent/episodes';
}

abstract class _RoutesBuilders {
  static GoRoute buildSignIn() {
    return GoRoute(
      name: _Routes.signIn,
      path: '/sign-in',
      builder: (context, state) => const SignInWidget(),
    );
  }

  static GoRoute buildMoviePlayer() {
    return GoRoute(
      name: _Routes.moviePlayer,
      path: '/movies/:movieId/player',
      pageBuilder: (context, state) => MaterialPage(
        fullscreenDialog: true,
        child: MoviePlayerWidget(
          movieId: .parse(state.pathParameters['movieId']!),
          initialEpisodeId: switch (state.uri.queryParameters['episodeId']) {
            final String episodeIdQuery => .tryParse(episodeIdQuery),
            _ => null,
          },
        ),
      ),
    );
  }

  static ShellRouteBase buildRootMenu() {
    final GoRoute search = _buildSearch();
    return StatefulShellRoute(
      branches: [
        StatefulShellBranch(routes: [_buildHome()]),
        StatefulShellBranch(routes: [_buildLibrary()]),
        StatefulShellBranch(routes: [search]),
      ],
      navigatorContainerBuilder: (context, navigationShell, children) =>
          RootMenuContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          ),
      builder: (context, state, navigationShell) => RootMenuView(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: RootMenuDestination.values,
        query: state.uri.queryParameters['query'],
        onSearch: (query) => context.goNamed(
          search.name!,
          queryParameters: {if (query.isNotEmpty) 'query': query},
        ),
        child: navigationShell,
      ),
    );
  }

  static GoRoute _buildHome() {
    final GoRoute upNext = _buildUpNext();
    final GoRoute search = _buildSearch(path: 'movies', parent: _Routes.home);
    final GoRoute movie = _buildMovie(parent: _Routes.home);
    return GoRoute(
      name: _Routes.home,
      path: '/',
      routes: [upNext, search, movie],
      builder: (context, state) => HomeWidget(
        upNextUri: .parse(state.namedLocation(upNext.name!)),
        onUpNextPressed: (movieId, episodeId) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': movieId.toString()},
          queryParameters: {'episodeId': episodeId.toString()},
        ),
        ongoingsUri: .parse(
          state.namedLocation(
            search.name!,
            queryParameters: {
              'isOngoing': true.toString(),
              'typesExcluded': [
                MovieType.ad.name,
                MovieType.music.name,
                MovieType.preview.name,
              ].join(','),
            },
          ),
        ),
        popularsUri: .parse(
          state.namedLocation(
            search.name!,
            queryParameters: {'order': MoviesOrder.byPopularity.name},
          ),
        ),
        onMoviePressed: (id) => context.pushNamed(
          movie.name!,
          pathParameters: {'movieId': id.toString()},
        ),
      ),
    );
  }

  static GoRoute _buildSearch({String path = '/search', String? parent}) {
    final String name = _Routes.search(parent: parent);
    final GoRoute movieRoute = _buildMovie(parent: name);
    return GoRoute(
      name: name,
      path: path,
      routes: [movieRoute],
      builder: (context, state) => MoviesSearchWidget(
        isOngoing: .tryParse(state.uri.queryParameters['isOngoing'] ?? ''),
        query: state.uri.queryParameters['query'],
        order: switch (state.uri.queryParameters['order']) {
          final String order => .valueOf(order),
          _ => .byPopularity,
        },
        typesExcluded:
            state.uri.queryParameters['typesExcluded']
                ?.split(',')
                .map(MovieType.values.byName)
                .toList(growable: false) ??
            const [],
        onSearch: (query) => context.replaceNamed(
          name,
          queryParameters: {if (query.isNotEmpty) 'query': query},
        ),
        onMoviePressed: (id) => context.pushNamed(
          movieRoute.name!,
          pathParameters: {'movieId': id.toString()},
        ),
      ),
    );
  }

  static GoRoute _buildMovie({required String parent}) {
    final GoRoute episodesRoute = _buildEpisodes(parent: parent);
    return GoRoute(
      name: _Routes.movie(parent: parent),
      path: 'movies/:movieId',
      routes: [episodesRoute],
      builder: (context, state) => MovieWidget(
        movieId: .parse(state.pathParameters['movieId']!),
        episodesUri: .parse(
          state.namedLocation(
            episodesRoute.name!,
            pathParameters: {'movieId': state.pathParameters['movieId']!},
          ),
        ),
        onPlayPressed: (episodeId) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': state.pathParameters['movieId']!},
          queryParameters: {'episodeId': episodeId.toString()},
        ),
        onEpisodePressed: (episodeId) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': state.pathParameters['movieId']!},
          queryParameters: {'episodeId': episodeId.toString()},
        ),
      ),
    );
  }

  static GoRoute _buildUpNext() {
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
        onItemLongPressed: (movieId, _) => context.pushNamed(
          movieRoute.name!,
          pathParameters: {'movieId': movieId.toString()},
        ),
      ),
    );
  }

  static GoRoute _buildEpisodes({required String parent}) {
    return GoRoute(
      name: _Routes.episodes(parent: parent),
      path: 'episodes',
      builder: (context, state) => EpisodesWidget(
        movieId: .parse(state.pathParameters['movieId']!),
        onEpisodePressed: (episodeId) => context.pushNamed(
          _Routes.moviePlayer,
          pathParameters: {'movieId': state.pathParameters['movieId']!},
          queryParameters: {'episodeId': episodeId.toString()},
        ),
      ),
    );
  }

  static GoRoute _buildLibrary() {
    final GoRoute movieRoute = _buildMovie(parent: _Routes.library);
    return GoRoute(
      name: _Routes.library,
      path: '/library',
      routes: [movieRoute],
      builder: (context, state) => LibraryWidget(
        onMoviePressed: (id) => context.pushNamed(
          movieRoute.name!,
          pathParameters: {'movieId': id.toString()},
        ),
      ),
    );
  }
}
