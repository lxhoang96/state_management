import 'package:collection/collection.dart';
import 'package:flutter/material.dart';


/// It is where your navigator flow starts.
/// Each [InitRouter] present a router later.
/// It contains a function returns Widget, [argumentNav] and [parentName] (optional)
final class InitRouter {
  final Widget Function() widget;
  final dynamic argumentNav;
  // final String? parentName;
  InitRouter({
    required this.widget,
    // this.parentName,
    this.argumentNav,
  });

  BaseRouter toBaseRouter(String routerName,
      {String? parentName, dynamic arguments}) {
    return BaseRouter(
      routerName: routerName,
      widget: widget,
      parentName: parentName,
      argumentNav: argumentNav,
      arguments: arguments,
    );
  }
}

/// A BaseRouter extends InitRouter to return a Router with
/// String [routerName] and List of BaseRouter [innerRouters] (optional)
final class BaseRouter {
  final String routerName;
  MaterialPage? page;
  late final LocalKey _key;
  final String? parentName;
  final dynamic arguments;
  final List<BaseRouter> innerRouters = [];
  final Widget Function() widget;
  final dynamic argumentNav;
  BaseRouter({
    required this.routerName,
    required this.widget,
    this.parentName,
    this.arguments,
    this.argumentNav,
  }) {
    _key = ValueKey(routerName);
  }

  MaterialPage _initRouter() {
    return MaterialPage(
        child: widget(), name: routerName, key: _key, arguments: arguments);
  }

  MaterialPage getRouter() {
    page ??= _initRouter();
    return page!;
  }
}

extension BaseRouterExtension on BaseRouter {
  addInner(BaseRouter innerRouter) => innerRouters.add(innerRouter);
  bool pop() {
    if (innerRouters.length <= 1) return false;
    innerRouters.removeLast();
    return true;
  }

  void popAllAndPushInner(BaseRouter innerRouter) => innerRouters
    ..clear()
    ..add(innerRouter);

  void popAndAddInner(BaseRouter innerRouter) {
    if (innerRouters.isNotEmpty) {
      innerRouters.removeLast();
    }

    innerRouters.add(innerRouter);
  }

  bool popUntil(String innerName) {
    if (innerRouters.length <= 1) return false;
    final index =
        innerRouters.indexWhere((element) => element.routerName == innerName);
    if (index >= 0) {
      innerRouters.length = index+1;
      return true;
    }
    return false;
  }
}

extension ConvertBaseRouter on List<BaseRouter> {
  List<MaterialPage> getMaterialPage() {
    return map((element) => element.getRouter()).toList();
  }

  BaseRouter? getByName(String routerName) =>
      firstWhereOrNull((element) => element.routerName == routerName);
}
