import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

extension _CSSStyleValue on web.CSSStyleValue {
  external String operator [](int index);
}

class WebMediaQuery extends StatefulWidget {
  const WebMediaQuery({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<WebMediaQuery> createState() => _WebMediaQueryState();
}

class _WebMediaQueryState extends State<WebMediaQuery> {
  static const String _leftInsetProperty = '--safe-area-insets-left';
  static const String _topInsetProperty = '--safe-area-insets-top';
  static const String _rightInsetProperty = '--safe-area-insets-right';
  static const String _bottomInsetProperty = '--safe-area-insets-bottom';

  final web.HTMLStyleElement _style = web.HTMLStyleElement()
    ..id = 'web-media-query'
    ..text = ':root { '
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
