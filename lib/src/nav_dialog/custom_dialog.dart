import 'package:base/src/base_component/light_observer.dart';
import 'package:base/src/interfaces/dialog_interfaces.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

class BaseDialog implements DialogInterfaces {
  static final instance = BaseDialog._();
  BaseDialog._();
  Widget dialog =
      Container(color: Colors.black.withOpacity(0.5), child: const SizedBox());

  @override
  showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    required InnerObserver<bool> barrierDismissible,
    Function? onClosed,
  }) {
    dialog = Scaffold(
      // type: MaterialType.transparency,
      backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.3),
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          ValueListenableBuilder(
              valueListenable: barrierDismissible,
              builder: (context, dimissible, _) {
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (dimissible) {
                      closeDialog(name, onClosed: onClosed);
                    }
                  },
                );
              }),
          Align(
            alignment: Alignment.center,
            child: child,
          ),
        ],
      ),
    );
    MainState.instance.showDialog(child: dialog, name: name);
  }

  @override
  closeDialog(
    String name, {
    Function? onClosed,
  }) {
    MainState.instance.removeDialog(name);
    onClosed?.call();
  }
}

class AppDialog {
  static final DialogInterfaces _baseDialog = BaseDialog.instance;

  static showDialog({
    required Widget child,
    required String name,
    Color? backgroundColor,
    required InnerObserver<bool> barrierDismissible,
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
