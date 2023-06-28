import 'appnav_interfaces.dart';

abstract interface class MainStateInterface implements AppNavInterfaces {
  /// add an intance to App state
  T add<T>(T instance, {permanently= false});

  void remove<T>();

  T find<T>();

  T addNew<T>(T instance, {permanently = false});
}
