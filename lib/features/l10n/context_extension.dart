import 'package:app/features/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);
}
