import 'dart:collection';

import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/controller_interface.dart';
import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:base/src/interfaces/mainstate_intefaces.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_2/custom_router.dart';
import 'package:base/src/nav_dialog/navigator_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The heart of the package, when you control how app navigate,
/// auto remove controller and observer
final class MainState implements MainStateInterface, DialogNavigatorInterfaces {
  static final instance = MainState._();
  MainState._();
  bool _isIntialized = false;
  intialize(
      {Function(dynamic e, String currentRouter)? onNavigationError}) async {
    if (_isIntialized) return;
    _isIntialized = true;

    _navApp = AppNav();
    _dialogNav = DialogNavigator();
    _queueNavigate = InnerObserver(initValue: Queue<Function>());

    // while (_isIntialized) {
    //   await Future.delayed(
    //     const Duration(milliseconds: 100),
    //   );
    //   if (_queueNavigate.isEmpty) continue;
    //   final oldFunc = _queueNavigate.removeFirst();
    //   try {
    //     oldFunc.call();
    //   } catch (e) {
    //     onNavigationError?.call(e, _navApp.currentRouter);
    //   }
    // }

    _queueNavigate.stream.listen((function) {
      while (function.isNotEmpty) {
        final oldFunc = _queueNavigate.value.removeFirst();
        try {
          oldFunc.call();
        } catch (e) {
          onNavigationError?.call(e, _navApp.currentRouter);
        }
      }
    });
  }

  final Map<Type, InstanceRoute> _listCtrl = {};
  final List<ObserverRoute> _listObserver = [];
  // final List<LightObserverRoute> _listLightObserver = [];
  late final AppNav _navApp;
  late final DialogNavigator _dialogNav;
  InnerObserver<List<MaterialPage>> get outerStream => _navApp.outerStream;
  InnerObserver<List<MaterialPage>> get dialogStream => _dialogNav.dialogStream;
  InnerObserver<List<MaterialPage>>? innerStream(String parentName) =>
      _navApp.getInnerStream(parentName);

  // bool _canNavigate = true;
  // final Queue<Function> _queueNavigate = Queue<Function>();
  late final InnerObserver<Queue<Function>> _queueNavigate;
  _HistoryOrder? _lastOrder;

  _checkCanNavigate(Function onNavigate, _HistoryOrder newOrder) {
    if (_lastOrder == newOrder) return;
    _lastOrder = newOrder;
    // _queueNavigate.add(onNavigate);
    _queueNavigate.value.add(onNavigate);
    _queueNavigate.update();
  }

  @override
  T add<T>(T instance, {permanently = false}) {
    final controller = _listCtrl[T]?.instance;
    if (controller != null) {
      return controller as T;
    } else {
      _listCtrl[T] = InstanceRoute(
          route: permanently ? '/' : _navApp.currentRouter,
          instance: instance,
          parentName: _navApp.parentRouter);
      if (instance is BaseController) {
        instance.init();
      }
      debugPrint("Added Controller Type:$T");
    }

    return instance;
  }

  @override
  addNew<T>(instance, {permanently = false}) {
    remove<T>();

    _listCtrl[T] = InstanceRoute(
        route: permanently ? '/' : _navApp.currentRouter,
        instance: instance,
        parentName: _navApp.parentRouter);
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
    final result = !_navApp.checkActiveRouter(instanceInput.route,
        parentName: instanceInput.parentName);
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
  }

  void _autoRemoveObs() {
    _listObserver.removeWhere((element) {
      final result = !_navApp.checkActiveRouter(element.route,
          parentName: element.parentName);
      if (result) {
        element.instance.dispose();
      }
      return result;
    });

    // _listLightObserver.removeWhere((element) {
    //   final result = !_navApp.checkActiveRouter(element.route,
    //       parentName: element.parentName);
    //   if (result) {
    //     debugPrint('Closing $element obs!');
    //     element.instance.dispose();
    //   }
    //   return result;
    // });
  }

  // @Deprecated('')
  void addObs(Observer observer) {
    _listObserver.add(ObserverRoute(
        route: _navApp.currentRouter,
        instance: observer,
        parentName: _navApp.parentRouter));
  }

  // void addLightObs(Observer observer) {
  //   _listLightObserver.add(LightObserverRoute(
  //       route: _navApp.currentRouter,
  //       instance: observer,
  //       parentName: _navApp.parentRouter));
  // }

  void _autoRemove() {
    _autoRemoveObs();
    _autoRemoveCtrl();
  }

  @override
  void pop() {
    _checkCanNavigate(() {
      _navApp.pop();
      _autoRemove();
    }, _HistoryOrder('pop', [_navApp.currentRouter]));
  }

  @override
  void popAllAndPushNamed(String routerName,
      {String? parentName, dynamic arguments}) {
    _checkCanNavigate(() {
      _navApp.popAllAndPushNamed(routerName,
          parentName: parentName, arguments: arguments);
      _autoRemove();
    },
        _HistoryOrder(
            'popAllAndPushNamed', [routerName, parentName, arguments]));
  }

  @override
  void popAndReplaceNamed(String routerName,
      {String? parentName, dynamic arguments}) {
    _checkCanNavigate(() {
      _navApp.popAndReplaceNamed(routerName,
          parentName: parentName, arguments: arguments);
      _autoRemove();
    },
        _HistoryOrder(
            'popAndReplaceNamed', [routerName, parentName, arguments]));
  }

  @override
  void popUntil(String routerName, {String? parentName}) {
    _checkCanNavigate(() {
      _navApp.popUntil(routerName, parentName: parentName);
      _autoRemove();
    }, _HistoryOrder('popUntil', [routerName, parentName]));
  }

  @override
  void pushNamed(String routerName, {String? parentName, dynamic arguments}) {
    _checkCanNavigate(() {
      _navApp.pushNamed(routerName,
          parentName: parentName, arguments: arguments);
    }, _HistoryOrder('pushNamed', [routerName, parentName, arguments]));
  }

  void setHomeRouter(String routerName) => _navApp.setHomeRouter(routerName);

  void goSplashScreen(String routerName) => _navApp.goSplashScreen(routerName);

  void setInitInnerRouter(String routerName, String parentName) =>
      _navApp.setInitInnerRouter(routerName, parentName);

  void setInitRouters(Map<String, InitRouter> initRouters) =>
      _navApp.setInitRouters(initRouters);

  void setInnerPagesForWeb(
          {required parentName,
          List<String> listRouter = const [],
          dynamic arguments}) =>
      _navApp.setInnerRoutersForWeb(
          parentName: parentName, listRouter: listRouter, arguments: arguments);

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
  get navigationArg => _navApp.navigationArg;

  @override
  get currentArguments => _navApp.currentArguments;
}

base class InstanceRoute<T> {
  final String route;
  final T instance;
  final String? parentName;

  InstanceRoute({required this.route, required this.instance, this.parentName});
}

final class ObserverRoute<Observer> extends InstanceRoute<Observer> {
  ObserverRoute(
      {required super.route, required super.instance, super.parentName});
}

final class LightObserverRoute<LightObserver>
    extends InstanceRoute<LightObserver> {
  LightObserverRoute(
      {required super.route, required super.instance, super.parentName});
}

final class _HistoryOrder {
  final String functionName;
  final List<dynamic> params;
  _HistoryOrder(this.functionName, this.params);

  @override
  bool operator ==(Object o) =>
      o is _HistoryOrder &&
      functionName == o.functionName &&
      listEquals(params, o.params);
}
