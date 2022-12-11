import 'package:flutter/foundation.dart';

abstract class BaseController {
  init();

  void dispose();
}

class DefaultController extends BaseController {
  DefaultController() {
    init();
  }

  @override
  void dispose() {
    debugPrint('${this} disposing');
   
  }

  @override
  init() {}

}
