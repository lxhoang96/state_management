import 'package:flutter/material.dart';

abstract class BaseController {
  init();

  onReady();

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

  @override
  onReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) => {});
  }
}
