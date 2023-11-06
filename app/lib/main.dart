import 'package:app/src/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  // TODO(ERGataullin): initialize all dependencies on a splash screen
  WidgetsFlutterBinding.ensureInitialized();

  final String? storagePath = kIsWeb
      ? null
      : await path_provider
          .getApplicationDocumentsDirectory()
          .then((directory) => directory.path);

  Hive.init(storagePath);

  const App().run();
}
