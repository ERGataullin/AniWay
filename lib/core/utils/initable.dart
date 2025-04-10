import 'dart:async';

import 'package:flutter/foundation.dart';

mixin Initable {
  @mustCallSuper
  FutureOr<void> init() {}

  @mustCallSuper
  FutureOr<void> dispose() {}
}
