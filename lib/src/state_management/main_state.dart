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

  getLast();
}

class MainState extends MainStateRepo {
  final Map<Type, InstanceRoute> _listCtrl = {};

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

  @override
  getLast() {
    return _listCtrl.values.last.controller;
  }

  String _getCurrentRoute() {
    if (AppRouter.listActiveRouter.isEmpty) {
      return AppRouter.initRoute;
    }
    return AppRouter.listActiveRouter.last;
  }
}

extension GlobalExtension on MainStateRepo {
  add(instance) => MainState().add(instance);

  void remove<T>() => MainState().remove<T>();

  T? find<T>() => MainState().find<T>();

  void addNew<T>(T newController) => MainState().addNew<T>(newController);

  void disposeAll() => MainState().disposeAll();

  void autoRemove() => MainState().autoRemove();

  dynamic getLast() => MainState().getLast();
}

class InstanceRoute {
  final String route;
  final DefaultController controller;

  InstanceRoute({required this.route, required this.controller});
}

final Global = MainState();
