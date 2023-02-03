import 'package:flutter/material.dart';

abstract class DialogNavigatorInterfaces {
  showDialog({required Widget child, required String name});

  removeDialog(String name);

  removeAllDialog();

  removeLastDialog();
}
