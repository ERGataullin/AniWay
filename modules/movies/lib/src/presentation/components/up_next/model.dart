import 'package:core/core.dart';

abstract interface class IUpNextModel implements ElementaryModel {}

class UpNextModel extends ElementaryModel implements IUpNextModel {
  UpNextModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);
}
