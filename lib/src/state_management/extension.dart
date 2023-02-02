import 'package:base/src/interfaces/mainstate_intefaces.dart';
import 'main_state.dart';




class Global {
  static final MainStateInterface _mainState = MainState.instance;

  static T add<T>(T instance) => _mainState.add(instance);

  static void remove<T>() => _mainState.remove<T>();

  static T find<T>() => _mainState.find<T>();

  static T addNew<T>(T newController) => _mainState.addNew<T>(newController);

  static void popAndReplacenamed(String routerName) =>
      _mainState.popAndReplaceNamed(routerName);

  static void pop() => _mainState.pop();

  static void popAllAndPushNamed(String routerName) =>
      _mainState.popAllAndPushNamed(routerName);

  static void popAndReplaceNamed(String routerName) =>
      _mainState.popAndReplaceNamed(routerName);

  static void popUntil(String routerName) => _mainState.popUntil(routerName);

  static void pushNamed(String routerName) => _mainState.pushNamed(routerName);

  static dynamic getCurrentArgument() => _mainState.getCurrentArgument();
}
