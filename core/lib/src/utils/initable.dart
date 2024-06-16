import 'dart:async';

import 'package:flutter/foundation.dart';

abstract interface class Initable {
  @mustCallSuper
  FutureOr<void> init();

  @mustCallSuper
  FutureOr<void> dispose();
}
