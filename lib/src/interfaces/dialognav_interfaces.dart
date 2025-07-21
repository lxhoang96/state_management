import 'package:flutter/material.dart';

abstract interface class DialogNavigatorInterfaces {
  showDialog({required Widget child, required String name});

  removeDialog(String name);

  removeAllDialog();

  removeLastDialog();

  bool isDialogOpen(String name);
}
