import 'package:flutter/material.dart';

abstract class DialogInterfaces {
  showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    bool barrierDismissible=true,
    Function? onClosed,
  });

  closeDialog(
    String name, {
    Function? onClosed,
  });
}
