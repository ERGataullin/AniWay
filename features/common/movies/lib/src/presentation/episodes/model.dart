import 'package:core/core.dart';

abstract interface class IEpisodesModel implements ElementaryModel {}

class EpisodesModel extends ElementaryModel implements IEpisodesModel {
  EpisodesModel({super.errorHandler});
}
