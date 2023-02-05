import 'package:base/base_navigation.dart';
import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';
import 'package:example/screen1/screen1.dart';
import 'package:example/screen2/screen2.dart';
import 'package:example/screen3/screen3.dart';

void main() {
  runApp(const MyApp());
}

Widget Function()? routerList(String name) {
  switch (name) {
    case RouteName.screen1:
      return () => Screen1();
    case RouteName.screen2:
      return () => Screen2();
    case RouteName.screen3:
      return () => Screen3();
    default:
      return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: HomeRouterDelegate(
          listPages: routerNewList, homeRouter: RouteName.screen1),
      routeInformationParser: HomeRouteInformationParser(),
    );
  }
}

Map<String, InitRouter> routerNewList = {
  RouteName.screen1: InitRouter(widget: () => Screen1()),
  RouteName.screen2: InitRouter(widget: () => Screen2()),
  RouteName.screen3: InitRouter(widget: () => Screen3()),
};
