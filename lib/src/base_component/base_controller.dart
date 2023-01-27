import 'package:flutter/material.dart';

/// controller interface 
abstract class BaseController {
  init();

  onReady();

  void dispose();
}

/// Controller is where you write your logic code
/// It should not be used to navigate.
/// controller life circle
/// init: start before screen is built first time
/// ready: start immediately after first time screen is built
/// dispose: called when router contains this controller is not in navigator stack
class DefaultController extends BaseController {
  @override
  void dispose() {
    debugPrint('$this disposing');
  }

  @override
  init() {
    WidgetsBinding.instance.addPostFrameCallback((_) => {onReady()});
  }

  @override
  onReady() {}

}
