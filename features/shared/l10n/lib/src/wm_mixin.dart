import 'package:core/core.dart';
import 'package:l10n/src/l10n.g.dart';

mixin L10nWMMixin<W extends ElementaryWidget, M extends ElementaryModel>
    on WidgetModel<W, M> {
  L10n get l10n => L10n.of(context);
}
