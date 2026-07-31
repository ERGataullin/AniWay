part of '../widget.dart';

class _AppBar extends StatelessWidget {
  const _AppBar();

  static bool isScrolledUnder(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!
        .isScrolledUnder!;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.loading,
      builder: (context, loading, _) {
        return SliverAppBar.large(
          pinned: true,
          expandedHeight: loading
              ? null
              : MediaQuery.sizeOf(context).width * 1.25,
          title: const _Title(),
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: Builder(
              builder: (context) {
                return ConditionalWrapper(
                  condition: !isScrolledUnder(context),
                  child: Icon(Icons.adaptive.arrow_back),
                  wrapper: (context, child) {
                    return IconTheme(
                      data: Theme.of(context).primaryIconTheme,
                      child: child,
                    );
                  },
                );
              },
            ),
          ),
          actions: loading ? null : const [_WatchStatusButton()],
          flexibleSpace: const _AppBarFlexibleSpace(),
        );
      },
    );
  }
}

class _WatchStatusButton extends StatelessWidget {
  const _WatchStatusButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.watchStatus,
      builder: (context, watchStatus, _) {
        return ConditionalWrapper(
          condition: !_AppBar.isScrolledUnder(context),
          wrapper: (context, child) {
            return IconTheme(
              data: Theme.of(context).primaryIconTheme,
              child: child,
            );
          },
          child: IconButton(
            onPressed: () => context.wm.handleWatchStatusPressed(context),
            isSelected: watchStatus != null,
            tooltip: switch (watchStatus) {
              null => context.l10n.watchStatusTitle,
              final WatchStatus other => context.l10n.watchStatus(other.name),
            },
            icon: const Icon(Icons.library_add_outlined),
            selectedIcon: const Icon(Icons.library_add_check_outlined),
          ),
        );
      },
    );
  }
}

class _AppBarFlexibleSpace extends StatelessWidget {
  const _AppBarFlexibleSpace();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.loading,
      builder: (context, loading, _) {
        return loading
            ? const SizedBox.shrink()
            : const FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Poster(),
                    _ToolbarBackgroundFade(),
                    _AppBarFooter(),
                  ],
                ),
              );
      },
    );
  }
}

class _ToolbarBackgroundFade extends StatelessWidget {
  const _ToolbarBackgroundFade();

  @override
  Widget build(BuildContext context) {
    final Color scrimColor = ColorScheme.of(context).scrim;
    return Align(
      alignment: .topCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            colors: [
              scrimColor.withValues(alpha: .5),
              scrimColor.withValues(alpha: 0),
            ],
          ),
        ),
        child: SizedBox(
          width: .infinity,
          height: AppBarTheme.of(context).toolbarHeight!,
        ),
      ),
    );
  }
}

class _AppBarFooter extends StatelessWidget {
  const _AppBarFooter();

  @override
  Widget build(BuildContext context) {
    final Color scrimColor = ColorScheme.of(context).scrim;
    return Align(
      alignment: .bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            stops: const [0, .25, .75, 1],
            colors: [
              scrimColor.withValues(alpha: 0),
              scrimColor.withValues(alpha: .5),
              scrimColor.withValues(alpha: .9),
              scrimColor,
            ],
          ),
        ),
        child: Padding(
          padding: .all(Breakpoint.activeBreakpointOf(context).margin),
          child: const Column(
            mainAxisSize: .min,
            mainAxisAlignment: .end,
            crossAxisAlignment: .start,
            children: [
              // Отступ для более плавного градиента.
              SizedBox(height: 32),
              _Score(),
              _Title(),
              SizedBox(height: 8),
              _Genres(),
            ],
          ),
        ),
      ),
    );
  }
}
