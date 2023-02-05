import 'package:base/base_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:test_newrouter/screen1/screen1_ctrl.dart';

class Screen3Controller extends DefaultController {
  final controller1 = Global.find<Screen1Controller>();
  final textCtrl = TextEditingController();

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }
}
