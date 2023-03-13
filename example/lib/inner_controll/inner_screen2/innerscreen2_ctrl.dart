import 'package:base/base_component.dart';
import 'package:flutter/cupertino.dart';

class InnerScreen2Controller extends DefaultController {
  final textCtrl = TextEditingController();

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }
}
