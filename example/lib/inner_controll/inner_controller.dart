import 'package:base/base_component.dart';
import 'package:example/routers/router_name.dart';

class InnerController extends DefaultController {
  final List<Function> navigateInner = [
    () => Global.popAndReplacenamed(RouteName.inner1),
    () => Global.popAndReplacenamed(RouteName.inner2),
  ];
}
