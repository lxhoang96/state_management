import 'package:base/base_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:example/screen1/screen1_ctrl.dart';

class Screen2Controller extends DefaultController {
  final controller1 = Global.find<Screen1Controller>();
  final textCtrl = TextEditingController();

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }
}
