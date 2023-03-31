import 'package:base/src/interfaces/mainstate_intefaces.dart';
import 'main_state.dart';

class Global {
  static final MainStateInterface _mainState = MainState.instance;

  static T add<T>(T instance) => _mainState.add(instance);

  static void remove<T>() => _mainState.remove<T>();

  static T find<T>() => _mainState.find<T>();

  static T addNew<T>(T newController) => _mainState.addNew<T>(newController);

  static void popAndReplaceNamed(String routerName,
          {String? parentName, dynamic arguments}) =>
      _mainState.popAndReplaceNamed(routerName,
          parentName: parentName, arguments: arguments);

  static void pop() => _mainState.pop();

  static void popAllAndPushNamed(String routerName,
          {String? parentName, dynamic arguments}) =>
      _mainState.popAllAndPushNamed(routerName,
          parentName: parentName, arguments: arguments);

  static void popUntil(String routerName) => _mainState.popUntil(routerName);

  static void pushNamed(String routerName,
          {String? parentName, dynamic arguments}) =>
      _mainState.pushNamed(routerName,
          parentName: parentName, arguments: arguments);

  static dynamic get currentArgumentNav => _mainState.navigationArg;

  static dynamic get currentArguments => _mainState.currentArguments;
}
