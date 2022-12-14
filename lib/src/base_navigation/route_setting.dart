import 'package:base/base_component.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const initRoute = '/';
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final List<String> listActiveRouter = [];

  static pushRoute(Route route, {GlobalKey<NavigatorState>? nestedKey}) {
    if (nestedKey != null) {
      nestedKey.currentState?.push(route);
    } else {
      navigatorKey.currentState?.push(route);
    }
  }

  static pushNamed(String name,
      {Object? argument, GlobalKey<NavigatorState>? nestedKey}) {
    listActiveRouter.add(name);
    if (nestedKey != null) {
      nestedKey.currentState?.pushNamed(name, arguments: argument);
    } else {
      navigatorKey.currentState?.pushNamed(name, arguments: argument);
    }
  }

  static pushReplacementNamed(String name,
      {Object? argument, GlobalKey<NavigatorState>? nestedKey}) {
    // if (navigatorKey.currentState?.canPop() ?? false) {
    if (listActiveRouter.isNotEmpty) listActiveRouter.removeLast();
    listActiveRouter.add(name);
    if (nestedKey != null) {
      nestedKey.currentState?.pushReplacementNamed(name, arguments: argument);
    } else {
      navigatorKey.currentState?.pushReplacementNamed(name, arguments: argument);
    }
    Global.autoRemove();
    // }
  }

  static pop({Object? argument, GlobalKey<NavigatorState>? nestedKey}) {
    debugPrint(navigatorKey.currentState?.canPop().toString());
    // if (navigatorKey.currentState?.canPop() ?? false) {
    if (listActiveRouter.isNotEmpty) listActiveRouter.removeLast();

    if (nestedKey != null) {
      nestedKey.currentState?.pop(argument);
    } else {
      navigatorKey.currentState?.pop(argument);
    }
    Global.autoRemove();
    // }
  }

  static popAllandPushNamed(String name,
      {Object? argument, GlobalKey<NavigatorState>? nestedKey}) {
    listActiveRouter.clear();
    listActiveRouter.add(name);

    if (nestedKey != null) {
      nestedKey.currentState
          ?.pushNamedAndRemoveUntil(name, (Route<dynamic> route) => false);
    } else {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil(name, (Route<dynamic> route) => false);
    }
    Global.autoRemove();
  }

  static popUntilNamed(String name, {GlobalKey<NavigatorState>? nestedKey}) {
    listActiveRouter.removeRange(
        listActiveRouter.indexOf(name) + 1, listActiveRouter.length);

    if (nestedKey != null) {
      nestedKey.currentState?.popUntil(ModalRoute.withName(name));
    } else {
      navigatorKey.currentState?.popUntil(ModalRoute.withName(name));
    }
    Global.autoRemove();
  }

  static removeRoute(Route route, {GlobalKey<NavigatorState>? nestedKey}) {
    if (route.isActive) {
      if (nestedKey != null) {
        nestedKey.currentState?.removeRoute(route);
      } else {
        navigatorKey.currentState?.removeRoute(route);
      }
    }
  }
}
