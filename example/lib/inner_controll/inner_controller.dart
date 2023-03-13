import 'package:base/base_component.dart';
import 'package:example/routers/router_name.dart';

class InnerController extends DefaultController {
  final List<Function> navigateInner = [
    () => Global.popAndReplaceNamed(RouteName.inner1,
        parentName: RouteName.innerControll),
    () => Global.popAndReplaceNamed(RouteName.inner2,
        parentName: RouteName.innerControll),
  ];
}
