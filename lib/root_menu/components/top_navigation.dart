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

  static const breakpoint = Breakpoints.mediumAndUp;

  final String? query;

  final OnMoviesSearch onSearch;

  @override
  Widget build(BuildContext context) {
    return SlotLayout(
      config: {
        breakpoint: SlotLayout.from(
          key: const Key('Top Navigation Medium and Up'),
          builder: (context) {
            final searchBar = MoviesSearchBar(
              query: query,
              onSearch: onSearch,
            );
            final leading = LayoutId(
              id: _SlotId.leading,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 + 16),
                child: Logo(enableRedirect: true),
              ),
            );
            final middle = LayoutId(id: _SlotId.middle, child: searchBar);

            return CustomMultiChildLayout(
              delegate: _LayoutDelegate(
                height: searchBar.preferredSize.height,
              ),
              children: [leading, middle],
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
