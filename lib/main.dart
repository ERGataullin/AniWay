import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO(ERGataullin): initialize all dependencies on a splash screen
  await path_provider
      .getApplicationDocumentsDirectory()
      .then((directory) => directory.path)
      .then(Hive.init);

  const App().run();
}
