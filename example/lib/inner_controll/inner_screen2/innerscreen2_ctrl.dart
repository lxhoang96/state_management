import 'package:base/base_component.dart';
import 'package:example/inner_controll/inner_screen1/innerscreen1_ctrl.dart';
import 'package:flutter/cupertino.dart';

class InnerScreen2Controller extends DefaultController {
  final controller1 = Global.find<InnerScreen1Controller>();
  final textCtrl = TextEditingController();

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }
}
