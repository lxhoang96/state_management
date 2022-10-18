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
}

class MainState extends MainStateRepo {
  final Map<Type, InstanceRoute> _listCtrl = {};

  @override
  T add<T>(T instance) {
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      return controller as T;
    } else {
      if (instance is BaseController) {
        instance.init();
      }
      _listCtrl[T] =
          InstanceRoute(route: _getCurrentRoute(), controller: instance);
      debugPrint("Added Controller Type:$T");
    }

    return instance;
  }

  @override
  addNew<T>(instance) {
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      if (controller is BaseController) {
        controller.dispose();
      }
      _listCtrl.remove(T);
    }
    if (instance is BaseController) {
      instance.init();
    }
    _listCtrl[T] =
        InstanceRoute(route: _getCurrentRoute(), controller: instance);
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
      if (controller is BaseController) {
        controller.dispose();
      }
      _listCtrl.remove(T);
      debugPrint("Removed Controller Type:$T");
    }
  }

  @override
  void disposeAll() {
    _listCtrl.forEach((key, element) {
      if (element.controller is BaseController) {
        element.controller.dispose();
      }
    });
  }

  String _getCurrentRoute() {
    if (AppRouter.listActiveRouter.isEmpty) {
      return AppRouter.initRoute;
    }
    return AppRouter.listActiveRouter.last;
  }

  @override
  void autoRemove() {
    _listCtrl.removeWhere((key, value) {
      final result = !AppRouter.listActiveRouter.contains(value.route) &&
          value.route != AppRouter.initRoute;
      if (result) {
        if (value.controller is BaseController) {
          value.controller.dispose();
        }
        debugPrint("Removed Controller Type:$key");
      }
      return result;
    });
    debugPrint('After deleted: ${_listCtrl.length}');
  }
}

extension GlobalExtension on MainStateRepo {
  add(instance) => MainState().add(instance);

  void remove<T>() => MainState().remove<T>();

  T? find<T>() => MainState().find<T>();

  void addNew<T>(T newController) => MainState().addNew<T>(newController);

  void disposeAll() => MainState().disposeAll();

  void autoRemove() => MainState().autoRemove();
}

class InstanceRoute {
  final String route;
  final dynamic controller;

  InstanceRoute({required this.route, required this.controller});
}

final Global = MainState();
