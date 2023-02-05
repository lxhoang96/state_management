import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// It is where your navigator flow starts.
/// Each [InitRouter] present a router later.
/// It contains a function returns Widget, [argument] and [parentName] (optional)
class InitRouter {
  final Widget Function() widget;
  final dynamic argument;
  final String? parentName;
  InitRouter({
    required this.widget,
    this.parentName,
    this.argument,
  });
  BaseRouter toBaseRouter(String routerName) {
    return BaseRouter(
      routerName: routerName,
      widget: widget,
      parentName: parentName,
      argument: argument,
    );
  }
}

/// A BaseRouter extends InitRouter to return a Router with
/// String [routerName] and List of BaseRouter [innerRouters] (optional)
class BaseRouter extends InitRouter {
  final String routerName;
  MaterialPage? page;
  late final LocalKey _key;
  final List<BaseRouter> innerRouters = [];
  BaseRouter({
    required this.routerName,
    required super.widget,
    super.parentName,
    super.argument,
  }) {
    _key = ValueKey(routerName);
  }

  MaterialPage _initRouter() {
    return MaterialPage(
        child: widget(), name: routerName, key: _key, arguments: argument);
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
    if (index > 0) {
      innerRouters.length = index;
      return true;
    }
    return false;
  }
}

extension ConvertBaseRouter on List<BaseRouter> {
  List<MaterialPage> getMaterialPage() {
    final List<MaterialPage> routers = [];
    forEach((element) {
      routers.add(element.getRouter());
    });
    return routers;
  }

  BaseRouter? getByName(String routerName) =>
      firstWhereOrNull((element) => element.routerName == routerName);
}
