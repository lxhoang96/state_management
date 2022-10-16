import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final List<String> listActiveRouter = [];
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

  static offAndPushNamed(String name, {Object? argument}) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      listActiveRouter.removeLast();
      listActiveRouter.add(name);
      navigatorKey.currentState?.popAndPushNamed(name, arguments: argument);
      Global.autoRemove();
    }
  }

  static pop({Object? argument}) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      listActiveRouter.removeLast();
      navigatorKey.currentState?.pop(argument);
      Global.autoRemove();
    }
  }

  static offAllandPushNamed(String name, {Object? argument}) {
    listActiveRouter.clear();
    listActiveRouter.add(name);
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(name, (Route<dynamic> route) => false);
    Global.autoRemove();
  }

  static popUntilNamed(String name) {
    listActiveRouter.removeRange(
        listActiveRouter.indexOf(name) + 1, listActiveRouter.length);
    navigatorKey.currentState?.popUntil(ModalRoute.withName(name));
    Global.autoRemove();
  }

  static removeRoute(Route route) {
    if (route.isActive) {
      navigatorKey.currentState?.removeRoute(route);
    }
  }
}
