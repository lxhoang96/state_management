import 'dart:collection';

import 'package:base/base_navigation.dart';
import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/controller_interface.dart';
import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:base/src/interfaces/mainstate_intefaces.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_dialog/navigator_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The heart of the package, when you control how app navigate,
/// auto remove controller and observer
class MainState extends MainStateInterface
    implements DialogNavigatorInterfaces {
  static final instance = MainState._();
  MainState._();
  bool _isIntialized = false;
  intialize({Function(dynamic e, String currentRouter)? onNavigationError}) {
    if (_isIntialized) return;

    _navApp = AppNav();
    _dialogNav = DialogNavigator();
    _queueNavigate = InnerObserver(initValue: Queue<Function>());

    _queueNavigate.stream.listen((function) {
      while (function.isNotEmpty) {
        final oldFunc = _queueNavigate.value.removeFirst();
        // try {
          oldFunc.call();
        // } catch (e) {
          // debugPrint(e.toString());
          // onNavigationError?.call(e, _navApp.currentRouter);
        // }
      }
    });
    _isIntialized = true;
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
  late final InnerObserver<Queue<Function>> _queueNavigate;
  _HistoryOrder? _lastOrder;

  _checkCanNavigate(Function onNavigate, _HistoryOrder newOrder) {
    if (_lastOrder == newOrder) return;
    _lastOrder = newOrder;
    _queueNavigate.value.add(onNavigate);
    _queueNavigate.update();
  }

  @override
  T add<T>(T instance) {
    final controller = _listCtrl[T]?.instance;
    if (controller != null) {
      return controller as T;
    } else {
      _listCtrl[T] = InstanceRoute(
          route: _navApp.currentRouter,
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
  addNew<T>(instance) {
    remove<T>();

    _listCtrl[T] = InstanceRoute(
        route: _navApp.currentRouter,
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
    final stopwatch = Stopwatch()..start();
    _listCtrl.removeWhere((key, value) {
      final result = _removeByInstance(value);
      if (result) {
        debugPrint("Removed Controller Type:$key");
      }
      return result;
    });
    debugPrint('After deleted: ${_listCtrl.length}');
    debugPrint('_autoRemoveCtrl() executed in ${stopwatch.elapsed}');
  }

  void _autoRemoveObs() {
    final stopwatch = Stopwatch()..start();
    _listObserver.removeWhere((element) {
      final result = !_navApp.checkActiveRouter(element.route,
          parentName: element.parentName);
      if (result) {
        element.instance.dispose();
      }
      return result;
    });
    debugPrint('_autoRemoveObs() executed in ${stopwatch.elapsed}');

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
    }, _HistoryOrder('pop', [null]));
    _autoRemove();
  }

  @override
  void popAllAndPushNamed(String routerName,
      {String? parentName, dynamic arguments}) {
    _checkCanNavigate(() {
      _navApp.popAllAndPushNamed(routerName,
          parentName: parentName, arguments: arguments);
    },
        _HistoryOrder(
            'popAllAndPushNamed', [routerName, parentName, arguments]));
    _autoRemove();
  }

  @override
  void popAndReplaceNamed(String routerName,
      {String? parentName, dynamic arguments}) {
    _checkCanNavigate(() {
      _navApp.popAndReplaceNamed(routerName,
          parentName: parentName, arguments: arguments);
    },
        _HistoryOrder(
            'popAndReplaceNamed', [routerName, parentName, arguments]));
    _autoRemove();
  }

  @override
  void popUntil(String routerName, {String? parentName}) {
    _checkCanNavigate(() {
      _navApp.popUntil(routerName, parentName: parentName);
    }, _HistoryOrder('popUntil', [routerName, parentName]));
    _autoRemove();
  }

  @override
  void pushNamed(String routerName, {String? parentName, dynamic arguments}) {
    _checkCanNavigate(() {
      _navApp.pushNamed(routerName,
          parentName: parentName, arguments: arguments);
    }, _HistoryOrder('pushNamed', [routerName, parentName, arguments]));
  }

  void setHomeRouter(String routerName) => _navApp.setHomeRouter(routerName);

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

class InstanceRoute<T> {
  final String route;
  final T instance;
  final String? parentName;

  InstanceRoute({required this.route, required this.instance, this.parentName});
}

class ObserverRoute<Observer> extends InstanceRoute<Observer> {
  ObserverRoute(
      {required super.route, required super.instance, super.parentName});
}

class LightObserverRoute<LightObserver> extends InstanceRoute<LightObserver> {
  LightObserverRoute(
      {required super.route, required super.instance, super.parentName});
}

class _HistoryOrder {
  final String functionName;
  final List<dynamic> params;
  _HistoryOrder(this.functionName, this.params);

  @override
  bool operator ==(Object o) =>
      o is _HistoryOrder &&
      functionName == o.functionName &&
      listEquals(params, o.params);
}
