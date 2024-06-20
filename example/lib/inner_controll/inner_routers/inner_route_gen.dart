import 'package:base/base_navigation.dart';
import 'package:example/inner_controll/inner_routers/inner_router_name.dart';
import 'package:example/inner_controll/inner_screen1/innerscreen1.dart';
import 'package:example/inner_controll/inner_screen2/innerscreen2.dart';

Map<String, InitRouter> innerRouterNewList = {

  RouteInnerName.inner1: InitRouter(
      widget: () => InnerScreen1()),
  RouteInnerName.inner2: InitRouter(
      widget: () => InnerScreen2()),
};
