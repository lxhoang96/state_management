import 'package:base/base_component.dart';
import 'package:example/inner_controll/inner_routers/inner_router_name.dart';
import 'package:example/routers/router_name.dart';

class InnerController extends DefaultController {
  final List<Function> navigateInner = [
    () => Global.popAndReplaceNamed(RouteInnerName.inner1,
        parentName: RouteName.innerControll),
    () => Global.popAndReplaceNamed(RouteInnerName.inner2,
        parentName: RouteName.innerControll),
  ];
}
