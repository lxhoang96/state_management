import 'package:base/src/base_component/base_observer.dart';
import 'package:flutter/material.dart';

abstract class DialogInterfaces {
  showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    required Observer<bool> barrierDismissible,
    Function? onClosed,
  });

  closeDialog(
    String name, {
    Function? onClosed,
  });
}
