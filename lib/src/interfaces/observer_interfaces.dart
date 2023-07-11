abstract interface class ObserverAbs<T> {
  void update();

  Stream<T> get stream;

  T get value;

  set value(T valueSet);

  dispose();
}
