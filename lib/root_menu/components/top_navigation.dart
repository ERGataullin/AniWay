import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/movies/movies.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

enum _SlotId { leading, middle }

class TopNavigation extends StatelessWidget {
  const TopNavigation({
    super.key,
    this.padding = .zero,
    this.query,
    required this.onSearch,
  });

  static const Breakpoint _breakpoint = Breakpoints.mediumAndUp;

  final EdgeInsets padding;

  final String? query;

  final OnMoviesSearch onSearch;

  static Size sizeFor(BuildContext context) {
    final Breakpoint? breakpoint = Breakpoint.activeBreakpointIn(
      context,
      const [_breakpoint],
    );
    return switch (breakpoint) {
      null => .zero,
      _breakpoint => .fromHeight(
        AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight,
      ),
      _ => throw UnsupportedError(
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
            final Size size = sizeFor(context);

            return Column(
              children: [
                AppBar(
                  centerTitle: true,
                  title: Padding(
                    padding: padding,
                    child: CustomMultiChildLayout(
                      delegate: _LayoutDelegate(size: size),
                      children: [
                        LayoutId(
                          id: _SlotId.leading,
                          child: const Logo(enableRedirect: true),
                        ),
                        LayoutId(
                          id: _SlotId.middle,
                          child: MoviesSearchBar(
                            margin: const .symmetric(vertical: 8),
                            query: query,
                            onSearch: onSearch,
                            theme: SearchBarThemeData(
                              elevation: const WidgetStatePropertyAll(0),
                              side: WidgetStatePropertyAll(
                                BorderSide(
                                  width: 0,
                                  color: ColorScheme.of(context).outlineVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      },
    );
  }
}

class _LayoutDelegate extends MultiChildLayoutDelegate {
  _LayoutDelegate({required this.size});

  static const spacing = 24.0;

  final Size size;

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return false;
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
      .new(maxWidth: size.width, maxHeight: size.height),
    );
    positionChild(
      _SlotId.leading,
      .new(0, (size.height - leadingSize.height) / 2),
    );
    occupiedWidth += leadingSize.width;

    occupiedWidth += spacing;

    final Size middleSize = layoutChild(
      _SlotId.middle,
      .new(maxWidth: size.width - occupiedWidth, maxHeight: size.height),
    );
    positionChild(
      _SlotId.middle,
      .new(
        max(occupiedWidth, (size.width - middleSize.width) / 2),
        (size.height - middleSize.height) / 2,
      ),
    );
  }
}
