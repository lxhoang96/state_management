import 'package:flutter/material.dart';

abstract interface class DialogInterfaces {
  showDialog({
    required Widget Function(BuildContext context) child,
    required String name,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Function? onClosed,
  });

  closeDialog(
    String name, {
    Function? onClosed,
  });
}
