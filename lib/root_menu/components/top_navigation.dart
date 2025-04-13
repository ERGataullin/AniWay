import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/movies/movies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

enum _SlotId { leading, middle }

class TopNavigation extends StatelessWidget {
  const TopNavigation({super.key, this.query, required this.onSearch});

  static const Breakpoint _breakpoint = Breakpoints.mediumAndUp;

  final String? query;

  final OnMoviesSearch onSearch;

  static Size sizeFor(BuildContext context) {
    final Breakpoint? breakpoint = Breakpoint.activeBreakpointIn(
      context,
      const [_breakpoint],
    );
    return switch (breakpoint) {
      null => Size.zero,
      _breakpoint => Size.fromHeight(
        (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight) +
            MediaQuery.paddingOf(context).top,
      ),
      _ =>
        throw UnsupportedError(
          'tried getting size for an unsupported breakpoint',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SlotLayout(
      config: {
        _breakpoint: SlotLayout.from(
          key: const Key('Top Navigation Medium and Up'),
          builder: (context) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            final Size size = sizeFor(context);

            return SizedBox(
              height: size.height,
              child: Theme(
                data: theme.copyWith(
                  colorScheme: colorScheme.copyWith(
                    surfaceContainer: colorScheme.surfaceContainerLowest,
                  ),
                ),
                child: AppBar(
                  centerTitle: true,
                  title: Theme(
                    data: theme,
                    child: CustomMultiChildLayout(
                      delegate: _LayoutDelegate(spacing: 24, size: size),
                      children: [
                        LayoutId(
                          id: _SlotId.leading,
                          child: const Logo(enableRedirect: true),
                        ),
                        LayoutId(
                          id: _SlotId.middle,
                          child: MoviesSearchBar(
                            query: query,
                            onSearch: onSearch,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      },
    );
  }
}

class _LayoutDelegate extends MultiChildLayoutDelegate {
  _LayoutDelegate({this.spacing = 0, required this.size});

  final double spacing;

  final Size size;

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return spacing != oldDelegate.spacing;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return size;
  }

  @override
  void performLayout(Size size) {
    double occupiedWidth = 0;

    final Size leadingSize = layoutChild(
      _SlotId.leading,
      BoxConstraints(maxWidth: size.width, maxHeight: size.height),
    );
    positionChild(
      _SlotId.leading,
      Offset(0, (size.height - leadingSize.height) / 2),
    );
    occupiedWidth += leadingSize.width;

    occupiedWidth += spacing;

    final Size middleSize = layoutChild(
      _SlotId.middle,
      BoxConstraints(
        maxWidth: size.width - occupiedWidth,
        maxHeight: size.height,
      ),
    );
    positionChild(
      _SlotId.middle,
      Offset(
        max(occupiedWidth, (size.width - middleSize.width) / 2),
        (size.height - middleSize.height) / 2,
      ),
    );
  }
}
