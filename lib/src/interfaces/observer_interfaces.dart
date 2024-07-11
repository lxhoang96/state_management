import 'dart:async';

abstract interface class ObserverAbs<T> {
  void update();

  Stream<T> get stream;

  T get value;

  set value(T valueSet);

  FutureOr<void> dispose();
}
