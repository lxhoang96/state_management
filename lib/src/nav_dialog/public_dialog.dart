import 'package:base/src/interfaces/dialog_interfaces.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

import 'custom_dialog.dart';

final class AppDialog {
  static final DialogInterfaces _baseDialog = BaseDialog.instance;

  static showDialog({
    required Widget Function(BuildContext context) child,
    required String name,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Function? onClosed,
  }) =>
      _baseDialog.showDialog(
          child: child,
          name: name,
          backgroundColor: backgroundColor,
          barrierDismissible: barrierDismissible,
          onClosed: onClosed);

  static closeDialog({required String name}) => _baseDialog.closeDialog(name);

  static closeAll() => MainState.instance.removeAllDialog();
}
