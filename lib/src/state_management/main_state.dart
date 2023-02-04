import 'package:base/base_component.dart';
import 'package:base/base_navigation.dart';
import 'package:base/src/base_component/base_controller.dart';
import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:base/src/interfaces/mainstate_intefaces.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_dialog/navigator_dialog.dart';
import 'package:flutter/material.dart';

/// The heart of the package, when you control how app navigate,
/// auto remove controller and observer
class MainState extends MainStateInterface
    implements DialogNavigatorInterfaces {
  static final instance = MainState._();
  MainState._();
  final Map<Type, InstanceRoute> _listCtrl = {};
  static final List<Observer> _listObserver = [];
  final _navApp = AppNav();
  final _dialogNav = DialogNavigator();

  Stream<List<MaterialPage<dynamic>>> get outerStream => _navApp.outerStream;
  Stream<List<MaterialPage<dynamic>>> get dialogStream =>
      _dialogNav.dialogStream;
  Stream<List<MaterialPage<dynamic>>>? innerStream(String parentName) =>
      _navApp.getInnerStream(parentName);

  @override
  T add<T>(T instance) {
    final controller = _listCtrl[T]?.instance;
    if (controller != null) {
      return controller as T;
    } else {
      _listCtrl[T] =
          InstanceRoute(route: _navApp.currentRouter, instance: instance);
      if (instance is BaseController) {
        instance.init();
      }
      debugPrint("Added Controller Type:$T");
    }

    return instance;
  }

  @override
  addNew<T>(instance) {
    remove<T>();

    _listCtrl[T] =
        InstanceRoute(route: _navApp.currentRouter, instance: instance);
    debugPrint("Added New Controller Type:$T");
    if (instance is BaseController) {
      instance.init();
    }
    return instance;
  }

  @override
  T find<T>() {
    final instance = _listCtrl[T]?.instance;
    if (instance == null) {
      throw Exception(
          ['Can not find $T, maybe you did not add this controller']);
    }
    return _listCtrl[T]?.instance;
  }

  @override
  remove<T>() {
    final instance = _listCtrl[T]?.instance;
    if (instance != null) {
      if (instance is BaseController) {
        instance.dispose();
      }
      _listCtrl.remove(instance);
      debugPrint("Removed Controller Type:$T");
    }
  }

  _removeByInstance(InstanceRoute instanceInput) {
    final result = !_navApp.checkActiveRouter(instanceInput.route);
    if (result) {
      final instance = instanceInput.instance;
      if (instance is BaseController) {
        instance.dispose();
      }
    }
    return result;
  }

  void _autoRemoveCtrl() {
    _listCtrl.removeWhere((key, value) {
      final result = _removeByInstance(value);
      if (result) {
        debugPrint("Removed Controller Type:$key");
      }
      return result;
    });
    debugPrint('After deleted: ${_listCtrl.length}');
  }

  void _autoRemoveObs() {
    _listObserver.removeWhere((element) {
      final result = !_navApp.checkActiveRouter(element.route);
      if (result) {
        debugPrint('Closing $element obs!');
        element.dispose();
      }
      return result;
    });
  }

  void addObs(Observer observer) {
    _listObserver.add(observer);
  }

  void _autoRemove() {
    _autoRemoveCtrl();
    _autoRemoveObs();
  }

  @override
  void pop() {
    _navApp.pop();
    _autoRemove();
  }

  @override
  void popAllAndPushNamed(String routerName) {
    _navApp.popAllAndPushNamed(routerName);
    _autoRemove();
  }

  @override
  void popAndReplaceNamed(String routerName) {
    _navApp.popAndReplaceNamed(routerName);
    _autoRemove();
  }

  @override
  void popUntil(String routerName) {
    _navApp.popUntil(routerName);
    _autoRemove();
  }

  @override
  void pushNamed(String routerName) => _navApp.pushNamed(routerName);

  void setHomeRouter(String routerName) => _navApp.setHomeRouter(routerName);

  void setInitInnerRouter(String routerName) =>
      _navApp.setInitInnerRouter(routerName);

  void setInitRouters(Map<String, InitRouter> initRouters) =>
      _navApp.setInitRouters(initRouters);

  void setInnerPagesForWeb(
          {required parentName, List<String> listRouter = const []}) =>
      _navApp.setInnerRoutersForWeb(
          parentName: parentName, listRouter: listRouter);

  void setOuterRoutersForWeb(List<String> listRouter) =>
      _navApp.setOuterRoutersForWeb(listRouter);

  void setUnknownRouter(String name) => _navApp.setUnknownRouter(name);

  void showHomeRouter() => _navApp.showHomeRouter();

  void showUnknownRouter() => _navApp.showUnknownRouter();

  getCurrentRouter() => _navApp.currentRouter;

  String getPath() => _navApp.getPath();

  @override
  getCurrentArgument() => _navApp.getCurrentArgument();

  void showLostConnectedRouter() => _navApp.showLostConnectedRouter();

  @override
  removeAllDialog() {
    _dialogNav.removeAllDialog();
  }

  @override
  removeDialog(String name) {
    _dialogNav.removeDialog(name);
  }

  @override
  showDialog({required Widget child, required String name}) {
    _dialogNav.showDialog(child: child, name: name);
  }

  @override
  removeLastDialog() {
    _dialogNav.removeLastDialog();
  }
}

class InstanceRoute<T> {
  final String route;
  final T instance;

  InstanceRoute({required this.route, required this.instance});
}
