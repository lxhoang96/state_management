import 'package:base/base_component.dart';
import 'package:flutter/cupertino.dart';

class InnerScreen1Controller extends DefaultController {
  final intObs = Observer(initValue: 0);
  final textCtrl = TextEditingController();

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }
}
