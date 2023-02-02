import 'package:base/base_component.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

class BaseDialog {
  static final instance = BaseDialog._();
  BaseDialog._();
  Widget dialog =
      Container(color: Colors.black.withOpacity(0.5), child: const SizedBox());

  showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    required Observer<bool> barrierDismissible,
    Function? onClosed,
  }) {
    dialog = Material(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Stack(
        children: [
          ObserWidget(
              value: barrierDismissible,
              child: (dimissible) {
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (dimissible) {
                      closeDialog(name);
                    }
                  },
                );
              }),
          Center(
            child: child,
          ),
        ],
      ),
    );
    MainState.instance.showDialog(child: child, name: name);
  }

  closeDialog(String name) {
    MainState.instance.removeDialog(name);
  }
}

class AppDialog {
  static final _baseDialog = BaseDialog.instance;
  static showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    required Observer<bool> barrierDismissible,
    Function? onClosed,
  }) =>
      _baseDialog.showDialog(
        child: child,
        name: name,
        backgroundColor: backgroundColor,
        barrierDismissible: barrierDismissible,
        onClosed: onClosed,
      );

  static closeDialog(String name) => _baseDialog.closeDialog(name);

  static closeAll() => MainState.instance.removeAllDialog();
}
