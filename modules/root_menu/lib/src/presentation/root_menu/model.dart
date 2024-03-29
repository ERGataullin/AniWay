import 'package:core/core.dart';

abstract interface class IRootMenuModel implements ElementaryModel {}

class RootMenuModel extends ElementaryModel implements IRootMenuModel {
  RootMenuModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);
}
