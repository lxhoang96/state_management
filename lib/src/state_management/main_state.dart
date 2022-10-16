import 'package:base/src/base_component/base_controller.dart';
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
  // static final MainState _singleton = MainState._internal();

  // factory MainState() {
  //   return _singleton;
  // }

  // MainState._internal();

  final Map<Type, InstanceRoute> _listCtrl = {};
  // Map<String, dynamic> _listBase = {};

  // List<BaseController> get getListCtrl => _listCtrl;

  @override
  T add<T>(T instance) {
    // if (instance is BaseController) {
    //   final appear = _listCtrl.values.firstWhereOrNull(
    //       (element) => element == instance);
    //   if (appear != null) {
    //     return appear as T;
    //   } else {
    //     instance.init();
    //     final _currentRoute = _getCurrentRoute();
    //     _listCtrl.(_currentRoute,instance);
    //   }
    // } else {
    //   final appear = _listBase.values.firstWhereOrNull(
    //       (element) => element == instance);
    //   if (appear != null) {
    //     return appear as T;
    //   } else {
    //     _listBase.add(instance);
    //   }
    // }
    // if(T != null)
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      return controller as T;
    } else {
      if (instance is BaseController) {
        instance.init();
      }
      _listCtrl[T] =
          InstanceRoute(route: _getCurrentRoute(), controller: instance);
      debugPrint("Added Controller Type:${T}");
    }

    return instance;
  }

  @override
  addNew<T>(instance) {
    // if (instance is BaseController) {
    //   final controller = _listCtrl.values.firstWhereOrNull(
    //       (element) => element == instance);
    //   if (controller != null) {
    //     _listCtrl.remove(controller);
    //   }
    //   _listCtrl.add(instance);
    // } else {
    //   final controller = _listBase.values.firstWhereOrNull(
    //       (element) => element == instance);
    //   if (controller != null) {
    //     _listBase.remove(controller);
    //   }
    //   _listBase.add(instance);
    // }

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
      debugPrint("Added New Controller Type:${T}");

    return instance;
  }

  @override
  T find<T>() {
    debugPrint(_listCtrl.length.toString());
    // if (T is BaseController) {
    //   return _listCtrl.firstWhereOrNull((element) => element == T)
    //       as T;
    // } else {
    //   return _listBase.firstWhereOrNull((element) {
    //     final result = element == T || element is T;
    //     return result;
    //   }) as T;
    // }
    return _listCtrl[T]?.controller as T;
  }

  @override
  remove<T>() {
    // if (T is BaseController) {
    //   final instance = _listCtrl.values
    //       .firstWhereOrNull((element) => element == T);
    //   if (instance != null) {
    //     instance.dispose();
    //     _listCtrl.removeWhere((key, value) => value == instance);
    //   }
    // } else {
    //   final instance = _listBase.values.firstWhereOrNull(
    //       (element) => element == T || element is T);
    //   if (instance != null) {
    //     _listBase.removeWhere((key, value) => value == instance);
    //   }
    // }
    final controller = _listCtrl[T]?.controller;
    if (controller != null) {
      if (controller is BaseController) {
        controller.dispose();
      }
      _listCtrl.remove(T);
      debugPrint("Added Controller Type:${T}");

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
      return '/';
    }
    return AppRouter.listActiveRouter.last;
  }

  @override
  void autoRemove() {
    _listCtrl.forEach((key, element) {
      if (!AppRouter.listActiveRouter.contains(element.route)) {
        _listCtrl.remove(key);
      debugPrint("Added Controller Type:$key");

      }
    });
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
