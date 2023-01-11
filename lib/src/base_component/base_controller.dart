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
  init() {
    WidgetsBinding.instance.addPostFrameCallback((_) => {
      onReady()
    });

  }

  @override
  onReady() {
  }
}
