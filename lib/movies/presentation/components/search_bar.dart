import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:flutter/material.dart';

typedef OnMoviesSearch = void Function(String query);

class MoviesSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const MoviesSearchBar({super.key, this.query, required this.onSearch});

  static const double margin = 8;

  final String? query;

  final OnMoviesSearch onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(margin + 56 + margin);

  @override
  State<MoviesSearchBar> createState() => _MoviesSearchBarState();
}

class _MoviesSearchBarState extends State<MoviesSearchBar> {
  static const Duration _debounce = Durations.medium3;

  late final TextEditingController _controller;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query)
      ..addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MoviesSearchBar oldWidget) {
    if (widget.query != _controller.text && widget.query?.isNotEmpty == true) {
      _controller.text = widget.query ?? '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    return ConditionalWrapper(
      condition: appBarTheme.systemOverlayStyle != null,
      wrapper:
          (context, child) => AnnotatedRegion(
            value: appBarTheme.systemOverlayStyle!,
            child: child,
          ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(MoviesSearchBar.margin),
          child: ListenableBuilder(
            listenable: _controller,
            builder:
                (context, _) => SearchBar(
                  controller: _controller,
                  hintText: context.l10n.searchPageTitle,
                  leading:
                      Navigator.canPop(context)
                          ? const BackButton()
                          : const IconButton(
                            onPressed: null,
                            icon: Icon(Icons.search_outlined),
                          ),
                  trailing:
                      _controller.text.isEmpty
                          ? null
                          : [
                            IconButton(
                              onPressed: _controller.clear,
                              icon: const Icon(Icons.clear_outlined),
                            ),
                          ],
                ),
          ),
        ),
      ),
    );
  }

  void _handleControllerChanged() {
    if (_controller.text == (widget.query ?? '')) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => widget.onSearch(_controller.text));
  }
}
