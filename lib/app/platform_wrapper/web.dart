import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

extension _CSSStyleValue on web.CSSStyleValue {
  external String operator [](int index);
}

class PlatformWrapper extends StatefulWidget {
  const PlatformWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<PlatformWrapper> createState() => _PlatformWrapperState();
}

class _PlatformWrapperState extends State<PlatformWrapper> {
  static const _leftInsetProperty = '--safe-area-insets-left';
  static const _topInsetProperty = '--safe-area-insets-top';
  static const _rightInsetProperty = '--safe-area-insets-right';
  static const _bottomInsetProperty = '--safe-area-insets-bottom';

  final _style =
      web.HTMLStyleElement()
        ..id = 'web-media-query'
        ..textContent =
            ':root { '
            '$_leftInsetProperty: env(safe-area-inset-left); '
            '$_topInsetProperty: env(safe-area-inset-top); '
            '$_rightInsetProperty: env(safe-area-inset-right); '
            '$_bottomInsetProperty: env(safe-area-inset-bottom); '
            '}';

  @override
  void initState() {
    super.initState();
    web.document.head?.appendChild(_style);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: EdgeInsets.fromLTRB(
          _getInset(_leftInsetProperty),
          _getInset(_topInsetProperty),
          _getInset(_rightInsetProperty),
          _getInset(_bottomInsetProperty),
        ),
        viewPadding: EdgeInsets.zero,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    web.document.head?.removeChild(_style);
    super.dispose();
  }

  double _getInset(String property) {
    final String cssRawValue = _style.computedStyleMap().get(property)![0];
    return double.parse(cssRawValue.substring(0, cssRawValue.length - 2));
  }
}
