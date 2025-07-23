import 'dart:async';

/// controller interface
abstract interface class BaseController {
  init();

  FutureOr<void> onReady();

  FutureOr<void> dispose();

  bool get isDisposed;
}