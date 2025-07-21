import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/nav_dialog/navigator_dialog.dart';
import 'package:base/src/nav_dialog/custom_dialog.dart';
import 'package:flutter/material.dart';

final class AppDialog {
  static final AppDialog _instance = AppDialog._();
  static AppDialog get instance => _instance;
  AppDialog._();

  // Internal dialog navigator - this manages the dialog state
  final DialogNavigator _dialogNavigator = DialogNavigator();

  // Expose the dialog stream for the UI
  InnerObserver<List<MaterialPage>> get dialogStream => _dialogNavigator.dialogStream;

  static showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Function? onClosed,
  }) {
    // Use CustomDialogStyles to create the styled dialog
    final styledDialog = CustomDialogStyles.createStyledDialog(
      child: child,
      backgroundColor: backgroundColor,
      barrierDismissible: barrierDismissible,
      onBarrierTap: () {
        if (barrierDismissible) {
          closeDialog(name: name);
          onClosed?.call();
        }
      },
    );

    // Use DialogNavigator to manage the dialog state
    _instance._dialogNavigator.showDialog(child: styledDialog, name: name);
  }

  static showBottomSheet({
    required Widget child,
    required String name,
    Color? backgroundColor,
    Function? onClosed,
  }) {
    final styledDialog = CustomDialogStyles.createBottomSheetDialog(
      child: child,
      backgroundColor: backgroundColor,
    );

    _instance._dialogNavigator.showDialog(child: styledDialog, name: name);
  }

  static closeDialog({required String name}) {
    _instance._dialogNavigator.removeDialog(name);
  }

  static closeAll() {
    _instance._dialogNavigator.removeAllDialog();
  }

  static closeLastDialog() {
    _instance._dialogNavigator.removeLastDialog();
  }

  static bool isDialogOpen(String name) {
    return _instance._dialogNavigator.isDialogOpen(name);
  }
}