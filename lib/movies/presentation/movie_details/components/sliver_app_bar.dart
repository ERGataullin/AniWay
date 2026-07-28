part of '../widget.dart';

class _SliverAppBar extends StatelessWidget {
  const _SliverAppBar();

  static bool isScrolledUnder(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!
        .isScrolledUnder!;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMediumAndUp = Breakpoints.mediumAndUp.isActive(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverAppBar.large(
          pinned: true,
          expandedHeight:
              isMediumAndUp
                  ? constraints.crossAxisExtent / (16 / 9)
                  : constraints.crossAxisExtent * 1.25,
          title: const _Title(),
          leading: const _BackButton(),
          actions: isMediumAndUp ? const [] : [const _WatchStatusButton()],
          flexibleSpace: const _AppBarFlexibleSpace(),
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.title,
      builder: (context, title, child) {
        return Text(title, style: style);
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final bool isScrolledUnder = _SliverAppBar.isScrolledUnder(context);
    return Center(
      child: AnimatedSwitcher(
        switchInCurve: Easing.standard,
        switchOutCurve: Easing.standard.flipped,
        duration: Durations.medium2,
        child: (isScrolledUnder ? IconButton.new : IconButton.filled)(
          key: ValueKey(isScrolledUnder),
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.adaptive.arrow_back),
        ),
      ),
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
        final Icon icon = switch (watchStatus) {
          null => const Icon(Icons.my_library_add_outlined),
          _ => const Icon(Icons.library_add_check_outlined),
        };
        final String text = switch (watchStatus) {
          null => context.l10n.watchStatusAdd,
          _ => context.l10n.watchStatusEdit,
        };
        return Breakpoints.mediumAndUp.isActive(context)
            ? FilledButton.icon(
              onPressed: context.wm.handleWatchStatusPressed,
              icon: icon,
              label: Text(text),
            )
            : (_SliverAppBar.isScrolledUnder(context)
                ? IconButton.new
                : IconButton.filledTonal)(
              onPressed: context.wm.handleWatchStatusPressed,
              tooltip: text,
              icon: icon,
            );
      },
    );
  }
}

class _AppBarFlexibleSpace extends StatelessWidget {
  const _AppBarFlexibleSpace();

  @override
  Widget build(BuildContext context) {
    final bool isMediumAndUp = Breakpoints.mediumAndUp.isActive(context);
    final EdgeInsets padding = context.marginAll;
    final BorderRadius borderRadius =
        isMediumAndUp
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : BorderRadius.zero;
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.pin,
      background: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Постер.
            const Padding(
              // Отступ от края для избежания 1 пикселя без затемнения на вебе.
              padding: EdgeInsets.all(1),
              child: _Poster(),
            ),

            // Данные и кнопки действий.
            Align(
              alignment: Alignment.bottomCenter,
              child: _FlexibleSpaceBarBottomBackground(
                child: Padding(
                  padding: padding,
                  child: Row(
                    spacing: context.padding,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(child: _FlexibleSpaceBarData()),
                      if (isMediumAndUp) const _FlexibleSpaceBarActions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.poster,
      builder: (context, poster, _) {
        return AdaptiveImageBuilder(
          image: poster,
          builder: (context, opacity, image, _) {
            return image == null
                ? const SizedBox.shrink()
                : Image(image: image, fit: BoxFit.cover, opacity: opacity);
          },
        );
      },
    );
  }
}

class _FlexibleSpaceBarBottomBackground extends StatelessWidget {
  const _FlexibleSpaceBarBottomBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color scrimColor = ColorScheme.of(context).scrim;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .25, .75, 1],
          colors: [
            scrimColor.withValues(alpha: 0),
            scrimColor.withValues(alpha: .5),
            scrimColor.withValues(alpha: .9),
            scrimColor,
          ],
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 2),
          child: child,
        ),
      ),
    );
  }
}

class _FlexibleSpaceBarData extends StatelessWidget {
  const _FlexibleSpaceBarData();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = TextTheme.primaryOf(context);
    final TextStyle? footerTextStyle = textTheme.labelSmall;
    return Column(
      spacing: context.padding,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: context.padding,
              children: [
                ValueListenableBuilder(
                  valueListenable: context.wm.score,
                  builder: (context, score, child) {
                    return MovieScore(score, textStyle: textTheme.titleMedium);
                  },
                ),
                Badge(
                  // TODO(Edgar): Заменить реальными данными.
                  label: const Text('Вышло'),
                  backgroundColor: Colors.greenAccent[700],
                ),
              ],
            ),
            _Title(style: textTheme.headlineMedium),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: context.wm.genres,
          builder: (context, genres, child) {
            return Text(genres.join('\u{00A0}· '));
          },
        ),
        // TODO(Edgar): Заменить реальными данными.
        Text.rich(
          TextSpan(
            style: footerTextStyle,
            children: [
              const TextSpan(
                text: '2009 - 2010',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' · 24 мин'),
              TextSpan(
                text: ' · 17+',
                style: TextStyle(
                  color: footerTextStyle?.color?.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlexibleSpaceBarActions extends StatelessWidget {
  const _FlexibleSpaceBarActions();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        spacing: context.padding,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [_WatchStatusButton(), _PlayButton()],
      ),
    );
  }
}
