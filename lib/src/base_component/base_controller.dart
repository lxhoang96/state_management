import 'package:base/src/interfaces/controller_interface.dart';
import 'package:flutter/material.dart';



/// Controller is where you write your logic code
/// It should not be used to navigate.
/// controller life circle
/// init: start before screen is built first time
/// ready: start immediately after first time screen is built
/// dispose: called when router contains this controller is not in navigator stack
base class DefaultController implements BaseController {
  @override
  void dispose() {
    debugPrint('$this disposing');
  }

  @override
  init() {
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  @override
  onReady() {}
}
