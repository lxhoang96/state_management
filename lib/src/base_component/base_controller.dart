import 'package:base/base_component.dart';
import 'package:flutter/foundation.dart';

abstract class BaseController {
  init();

  void dispose();
}

class DefaultController extends BaseController {
  DefaultController({this.instance});
  final dynamic instance;
  final List<Observer> listObs = [];
  @override
  void dispose() {
    debugPrint('${this} disposing');
    for (var element in listObs) {
      element.dispose();
    }
  }

  @override
  init() {}
}
