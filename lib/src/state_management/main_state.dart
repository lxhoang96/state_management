import 'dart:collection';

import 'package:base/base_navigation.dart';
import 'package:base/src/base_component/base_controller.dart';
import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/base_component/light_observer.dart';
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

  intialize() {
    _navApp = AppNav();
    _dialogNav = DialogNavigator();
    _queueNavigate = LightObserver(Queue<Function>());
    _queueNavigate.addListener(() async {
      while (_queueNavigate.value.isNotEmpty) {
        final function = _queueNavigate.value.removeFirst();
        function.call();
      }
    });
  }

  final Map<Type, InstanceRoute> _listCtrl = {};
  final List<ObserverRoute> _listObserver = [];
  final List<LightObserverRoute> _listLightObserver = [];
  late final AppNav _navApp;
  late final DialogNavigator _dialogNav;

  LightObserver<List<MaterialPage>> get outerStream => _navApp.outerStream;
  LightObserver<List<MaterialPage>> get dialogStream => _dialogNav.dialogStream;
  LightObserver<List<MaterialPage>>? innerStream(String parentName) =>
      _navApp.getInnerStream(parentName);

  // bool _canNavigate = true;
  late final LightObserver<Queue<Function>> _queueNavigate;
  _HistoryOrder? _lastOrder;

  _checkCanNavigate(Function onNavigate, _HistoryOrder newOrder) {
    final value = _queueNavigate.value;
    if (_lastOrder == newOrder) return;
    // final newQueue = Queue<Function>.from(_queueNavigate.value);
    // newQueue.addLast(onNavigate);
    _lastOrder = newOrder;
    value.add(onNavigate);
    _queueNavigate.newValue = value;
  }

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
        element.instance.dispose();
      }
      return result;
    });

    _listLightObserver.removeWhere((element) {
      final result = !_navApp.checkActiveRouter(element.route);
      if (result) {
        debugPrint('Closing $element obs!');
        element.instance.dispose();
      }
      return result;
    });
  }

  void addObs(Observer observer) {
    _listObserver
        .add(ObserverRoute(route: _navApp.currentRouter, instance: observer));
  }

  void addLightObs(LightObserver observer) {
    _listLightObserver.add(
        LightObserverRoute(route: _navApp.currentRouter, instance: observer));
  }

  void _autoRemove() {
    _autoRemoveCtrl();
    _autoRemoveObs();
  }

  @override
  void pop() {
    _checkCanNavigate(() {
      _navApp.pop();
      _autoRemove();
    }, _HistoryOrder('pop', null));
  }

  @override
  void popAllAndPushNamed(String routerName) {
    _checkCanNavigate(() {
      _navApp.popAllAndPushNamed(routerName);
      _autoRemove();
    }, _HistoryOrder('popAllAndPushNamed', routerName));
  }

  @override
  void popAndReplaceNamed(String routerName, {String? parentName}) {
    _checkCanNavigate(() {
      _navApp.popAndReplaceNamed(routerName, parentName: parentName);
      _autoRemove();
    }, _HistoryOrder('popAndReplaceNamed', routerName));
  }

  @override
  void popUntil(String routerName) {
    _checkCanNavigate(() {
      _navApp.popUntil(routerName);
      _autoRemove();
    }, _HistoryOrder('popUntil', routerName));
  }

  @override
  void pushNamed(String routerName, {String? parentName}) {
    _checkCanNavigate(() {
      _navApp.pushNamed(routerName, parentName: parentName);
    }, _HistoryOrder('pushNamed', routerName));
  }

  void setHomeRouter(String routerName) => _navApp.setHomeRouter(routerName);

  void setInitInnerRouter(String routerName, String parentName) =>
      _navApp.setInitInnerRouter(routerName, parentName);

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

  String getCurrentRouter() => _navApp.currentRouter;

  String getPath() => _navApp.getPath();

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
  @override
  get argument => _navApp.argument;
}

class InstanceRoute<T> {
  final String route;
  final T instance;

  InstanceRoute({required this.route, required this.instance});
}

class ObserverRoute<Observer> extends InstanceRoute<Observer> {
  ObserverRoute({required super.route, required super.instance});
}

class LightObserverRoute<LightObserver> extends InstanceRoute<LightObserver> {
  LightObserverRoute({required super.route, required super.instance});
}

class _HistoryOrder {
  final String functionName;
  final dynamic params;
  _HistoryOrder(this.functionName, this.params);

  @override
  bool operator ==(Object o) =>
      o is _HistoryOrder &&
      functionName == o.functionName &&
      params == o.params;
}
