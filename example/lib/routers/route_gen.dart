import 'package:base/base_navigation.dart';
import 'package:example/inner_controll/inner_screen.dart';
import 'package:example/inner_controll/inner_screen1/innerscreen1.dart';
import 'package:example/inner_controll/inner_screen2/innerscreen2.dart';
import 'package:example/routers/router_name.dart';
import 'package:example/screen1/screen1.dart';
import 'package:example/screen2/screen2.dart';
import 'package:example/screen3/screen3.dart';

Map<String, InitRouter> routerNewList = {
  RouteName.screen1: InitRouter(widget: () => Screen1()),
  RouteName.screen2: InitRouter(widget: () => Screen2()),
  RouteName.screen3: InitRouter(widget: () => Screen3()),
  RouteName.innerControll: InitRouter(widget: () => InnerScreen()),
  RouteName.inner1: InitRouter(
      widget: () => InnerScreen1()),
  RouteName.inner2: InitRouter(
      widget: () => InnerScreen2()),
};
