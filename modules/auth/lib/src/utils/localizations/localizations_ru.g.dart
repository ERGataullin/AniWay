import 'localizations.g.dart';

/// The translations for Russian (`ru`).
class AuthLocalizationsRu extends AuthLocalizations {
  AuthLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get signInEmailLabel => 'Электронная почта';

  @override
  String get signInEmailInvalidError => 'Неверный адрес электронной почты';

  @override
  String get signInPasswordLabel => 'Пароль';

  @override
  String get singInSubmitLabel => 'Войти';

  @override
  String get signInTitle => 'Авторизация';
}
