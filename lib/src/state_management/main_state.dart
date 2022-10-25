import 'package:base/base_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../base_navigation/route_setting.dart';

abstract class MainStateRepo {
  T add<T>(T instance);

  void remove<T>();

  void autoRemove();

  T find<T>();

  T addNew<T>(T instance);

  void disposeAll();

  void addObs(Observer observer);

  void autoRemoveObs();
}

class MainState extends MainStateRepo {
  final Map<Type, InstanceRoute> _listCtrl = {};
  static final List<Observer> _listObserver = [];

  @override
  T add<T>(T instance) {
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      return controller as T;
    } else {
      final DefaultController controller;
      if (instance is BaseController) {
        controller = instance as DefaultController;
        instance.init();
      } else {
        controller = DefaultController(instance: instance);
      }
      _listCtrl[T] =
          InstanceRoute(route: _getCurrentRoute(), controller: controller);
      debugPrint("Added Controller Type:$T");
    }

    return instance;
  }

  @override
  addNew<T>(instance) {
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      controller.dispose();
      _listCtrl.remove(T);
    }
    final DefaultController newController;
    if (instance is BaseController) {
      newController = instance as DefaultController;
      instance.init();
    } else {
      newController = DefaultController(instance: instance);
    }
    _listCtrl[T] =
        InstanceRoute(route: _getCurrentRoute(), controller: newController);
    debugPrint("Added New Controller Type:$T");

    return instance;
  }

  @override
  T find<T>() {
    if (_listCtrl[T]?.controller.instance != null) {
      return _listCtrl[T]?.controller.instance as T;
    }
    return _listCtrl[T]?.controller as T;
  }

  @override
  remove<T>() {
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      controller.dispose();
      _listCtrl.remove(T);
      debugPrint("Removed Controller Type:$T");
    }
  }

  @override
  void disposeAll() {
    _listCtrl.forEach((key, element) {
      element.controller.dispose();
    });
  }

  @override
  void autoRemove() {
    _listCtrl.removeWhere((key, value) {
      final result = !AppRouter.listActiveRouter.contains(value.route) &&
          value.route != AppRouter.initRoute;
      if (result) {
        value.controller.dispose();
        debugPrint("Removed Controller Type:$key");
      }
      return result;
    });
    debugPrint('After deleted: ${_listCtrl.length}');
  }

  String _getCurrentRoute() {
    if (AppRouter.listActiveRouter.isEmpty) {
      return AppRouter.initRoute;
    }
    return AppRouter.listActiveRouter.last;
  }

  @override
  autoRemoveObs() {
    _listObserver.removeWhere((element) {
      final result = AppRouter.listActiveRouter.contains(element.route) ||
          element.route == AppRouter.initRoute;
      if (!result) {
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
}

class InstanceRoute {
  final String route;
  final DefaultController controller;

  InstanceRoute({required this.route, required this.controller});
}

final Global = MainState();
