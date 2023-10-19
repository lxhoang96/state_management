import 'package:base/base_navigation.dart';
import 'package:example/routers/route_gen.dart';
import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: HomeRouterDelegate(
          listPages: routerNewList, homeRouter: RouteName.screen1),
      routeInformationParser: HomeRouteInformationParser(),
      theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CustomTransitionBuilder(),
              TargetPlatform.iOS: CustomTransitionBuilder(),
              TargetPlatform.macOS: CustomTransitionBuilder(),
              TargetPlatform.windows: CustomTransitionBuilder(),
              TargetPlatform.linux: CustomTransitionBuilder(),
            },
          ),
          useMaterial3: true,
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent)),
    );
  }
}
