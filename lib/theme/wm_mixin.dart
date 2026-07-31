import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin ThemeWMMixin<W extends ElementaryWidget, M extends ElementaryModel>
    on WidgetModel<W, M> {
  late final ValueNotifier<ThemeData> _theme;

  var _initialized = false;

  ValueListenable<ThemeData> get theme => _theme;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (_initialized) {
      _theme.value = Theme.of(context);
    } else {
      _theme = .new(Theme.of(context));
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }
}
