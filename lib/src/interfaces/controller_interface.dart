import 'dart:async';

/// controller interface
abstract interface class BaseController {
  FutureOr<void> init();

  FutureOr<void> onReady();

  FutureOr<void> dispose();
}