import 'package:base/src/interfaces/dialog_interfaces.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

final class BaseDialog implements DialogInterfaces {
  static final instance = BaseDialog._();
  BaseDialog._();
  Widget _dialog =
      Container(color: Colors.black.withOpacity(0.5), child: const SizedBox());
  late final BuildContext _dialogContext;
  bool _isInit = false;
  init(BuildContext context) {
    if (_isInit) return;
    _dialogContext = context;
    _isInit = true;
  }

  @override
  showDialog({
    required Widget Function(BuildContext context) child,
    required String name,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Function? onClosed,
  }) {
    _dialog = Scaffold(
      // type: MaterialType.transparency,
      backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.3),
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (barrierDismissible) {
                closeDialog(name, onClosed: onClosed);
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: child.call(_dialogContext),
          ),
        ],
      ),
    );
    MainState.instance.showDialog(child: _dialog, name: name);
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
