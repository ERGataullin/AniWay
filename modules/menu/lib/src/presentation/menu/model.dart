import 'package:elementary/elementary.dart';

abstract interface class IMenuModel implements ElementaryModel {}

class MenuModel extends ElementaryModel implements IMenuModel {
  MenuModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);
}
