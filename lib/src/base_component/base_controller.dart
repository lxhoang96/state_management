import 'package:flutter/foundation.dart';

abstract class BaseController {
  init();

  void dispose();
}

class DefaultController extends BaseController {
  DefaultController();

  @override
  void dispose() {
    debugPrint('${this} disposing');
  }

  @override
  init() {}
}
