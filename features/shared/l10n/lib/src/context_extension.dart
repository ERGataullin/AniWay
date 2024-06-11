import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';

extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);
}
