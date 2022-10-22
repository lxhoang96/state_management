import 'package:base/base_component.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const initRoute = '/';
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final List<String> listActiveRouter = [];
  static final List<Observer> listObserver = [];
  // static push(Widget page) {
  //   navigatorKey.currentState?.push(
  //     MaterialPageRoute(builder: (_) => page),
  //   );
  // }

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
      autoRemoveObserver();
    // }
  }

  static pop({Object? argument}) {
    debugPrint(navigatorKey.currentState?.canPop().toString());
    // if (navigatorKey.currentState?.canPop() ?? false) {
      if (listActiveRouter.isNotEmpty) listActiveRouter.removeLast();

      navigatorKey.currentState?.pop(argument);
      Global.autoRemove();
      autoRemoveObserver();
    // }
  }

  static popAllandPushNamed(String name, {Object? argument}) {
    listActiveRouter.clear();
    listActiveRouter.add(name);
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(name, (Route<dynamic> route) => false);
    Global.autoRemove();
    autoRemoveObserver();
  }

  static popUntilNamed(String name) {
    listActiveRouter.removeRange(
        listActiveRouter.indexOf(name) + 1, listActiveRouter.length);
    navigatorKey.currentState?.popUntil(ModalRoute.withName(name));
    Global.autoRemove();
    autoRemoveObserver();
  }

  static removeRoute(Route route) {
    if (route.isActive) {
      navigatorKey.currentState?.removeRoute(route);
    }
  }

  static autoRemoveObserver() {
    listObserver.removeWhere((element) {
      final result = listActiveRouter.contains(element.route) ||
          element.route == initRoute;
      if (!result) {
        debugPrint('Closing $element obs!');
        element.dispose();
      }
      return result;
    });
  }
}
