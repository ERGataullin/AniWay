import 'package:app/core/core.dart';
import 'package:app/features/l10n/l10n.dart';
import 'package:flutter/foundation.dart';

mixin L10nWMMixin<W extends ElementaryWidget, M extends ElementaryModel>
    on WidgetModel<W, M> {
  late final ValueNotifier<L10n> _l10n;

  bool _initialized = false;

  ValueListenable<L10n> get l10n => _l10n;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (_initialized) {
      _l10n.value = L10n.of(context);
    } else {
      _l10n = ValueNotifier(L10n.of(context));
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _l10n.dispose();
    super.dispose();
  }
}
