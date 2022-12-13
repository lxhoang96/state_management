import 'package:base/base_component.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const initRoute = '/';
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final List<String> listActiveRouter = [];
  static String? get currentRouter =>
      listActiveRouter.isNotEmpty ? listActiveRouter.last : null;

  static pushRoute(Route route) {
    navigatorKey.currentState?.push(route);
  }

  static pushNamed(String name, {Object? argument}) {
    listActiveRouter.add(name);
    navigatorKey.currentState?.pushNamed(name, arguments: argument);
  }

  static popAndPushNamed(String name, {Object? argument}) {
    // if (navigatorKey.currentState?.canPop() ?? false) {
    if (listActiveRouter.isNotEmpty) listActiveRouter.removeLast();
    listActiveRouter.add(name);
    navigatorKey.currentState?.popAndPushNamed(name, arguments: argument);
    Global.autoRemove();
    Global.autoRemoveObs();
    // }
  }

  static pop({Object? argument}) {
    debugPrint(navigatorKey.currentState?.canPop().toString());
    // if (navigatorKey.currentState?.canPop() ?? false) {
    if (listActiveRouter.isNotEmpty) listActiveRouter.removeLast();

    navigatorKey.currentState?.pop(argument);
    Global.autoRemove();
    Global.autoRemoveObs();
    // }
  }

  static popAllandPushNamed(String name, {Object? argument}) {
    listActiveRouter.clear();
    listActiveRouter.add(name);
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(name, (Route<dynamic> route) => false);
    Global.autoRemove();
    Global.autoRemoveObs();
  }

  static popUntilNamed(String name) {
    listActiveRouter.removeRange(
        listActiveRouter.indexOf(name) + 1, listActiveRouter.length);
    navigatorKey.currentState?.popUntil(ModalRoute.withName(name));
    Global.autoRemove();
    Global.autoRemoveObs();
  }

  static removeRoute(Route route) {
    if (route.isActive) {
      navigatorKey.currentState?.removeRoute(route);
    }
  }
}
