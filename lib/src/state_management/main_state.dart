import 'package:base/base_component.dart';
import 'package:base/src/base_navigation/route_setting.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

abstract class MainStateRepo {
  /// add an intance to App state
  T add<T>(T instance);

  void remove<T>();

  T find<T>();

  T addNew<T>(T instance);

  void addObs(Observer observer);
}

class MainState extends MainStateRepo {
  final Map<Type, InstanceRoute> _listCtrl = {};
  static final List<Observer> _listObserver = [];

  @override
  T add<T>(T instance) {
    final controller = _listCtrl[T]?.instance;
    if (controller != null) {
      return controller as T;
    } else {
      _listCtrl[T] =
          InstanceRoute(route: AppRouter.currentRouter, instance: instance);
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
        InstanceRoute(route: AppRouter.currentRouter, instance: instance);
    debugPrint("Added New Controller Type:$T");
    if (instance is BaseController) {
      instance.init();
    }
    return instance;
  }

  @override
  T find<T>() {
    // if (_listCtrl[T]?.instance != null) {
    //   return _listCtrl[T]?.instance as T;
    // }
    return _listCtrl[T]?.instance as T;
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
    final result = AppRouter.listActiveRouter
            .firstWhereOrNull((element) => element == instanceInput.route) ==
        null;
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
      if (element.route == null) return false;
      final result = AppRouter.listActiveRouter
              .firstWhereOrNull((router) => router == element.route) ==
          null;
      if (result) {
        debugPrint('Closing $element obs!');
        element.dispose();
      }
      return result;
    });
  }

  @override
  void addObs(Observer observer) {
    _listObserver.add(observer);
  }

  void autoRemove() {
    _autoRemoveCtrl();
    _autoRemoveObs();
  }
}

class InstanceRoute<T> {
  final String route;
  final T instance;

  InstanceRoute({required this.route, required this.instance});
}

final Global = MainState();
