import 'appnav_interfaces.dart';

abstract class MainStateInterface extends AppNavInterfaces {
  /// add an intance to App state
  T add<T>(T instance);

  void remove<T>();

  T find<T>();

  T addNew<T>(T instance);
}
