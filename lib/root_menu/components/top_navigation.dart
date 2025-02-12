import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/movies/movies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

enum _SlotId { leading, middle }

class TopNavigation extends StatelessWidget {
  const TopNavigation({
    super.key,
    this.query,
    required this.onSearch,
  });

  static const Breakpoint breakpoint = Breakpoints.mediumAndUp;

  final String? query;

  final OnMoviesSearch onSearch;

  @override
  Widget build(BuildContext context) {
    return SlotLayout(
      config: {
        breakpoint: SlotLayout.from(
          key: const Key('Top Navigation Medium and Up'),
          builder: (context) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            final double appBarHeight =
                theme.appBarTheme.toolbarHeight ?? kToolbarHeight;

            return SizedBox(
              height: appBarHeight,
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
                      delegate: _LayoutDelegate(height: appBarHeight),
                      children: [
                        LayoutId(
                          id: _SlotId.leading,
                          child: const Logo(enableRedirect: false),
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
  _LayoutDelegate({required this.height});

  final double height;

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return false;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints
        .copyWith(
          minHeight: height,
          maxHeight: height,
        )
        .biggest;
  }

  @override
  void performLayout(Size size) {
    final Size leadingSize = layoutChild(
      _SlotId.leading,
      BoxConstraints(
        maxWidth: size.width,
        maxHeight: size.height,
      ),
    );
    positionChild(
      _SlotId.leading,
      Offset(0, (size.height - leadingSize.height) / 2),
    );

    final Size middleSize = layoutChild(
      _SlotId.middle,
      BoxConstraints(
        maxWidth: size.width - leadingSize.width,
        maxHeight: size.height,
      ),
    );
    positionChild(
      _SlotId.middle,
      Offset(
        max(leadingSize.width, (size.width - middleSize.width) / 2),
        (size.height - middleSize.height) / 2,
      ),
    );
  }
}
