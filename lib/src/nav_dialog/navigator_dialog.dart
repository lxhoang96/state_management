import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:flutter/material.dart';

class DialogNavigator implements DialogNavigatorInterfaces {
  final List<MaterialPage> listDialog = [];

  /// The Navigator stack is updated with these stream
  /// [_streamDialogController] for dialog flow
  final _streamDialogController =
      InnerObserver<List<MaterialPage>>(initValue: []);

  InnerObserver<List<MaterialPage>> get dialogStream => _streamDialogController;

  @override
  showDialog({required Widget child, required String name}) {
    listDialog.add(MaterialPage(
        child: child,
        // fullscreenDialog: true,
        maintainState: false,
        key: ValueKey(name),
        name: name));
    _streamDialogController.value = listDialog;
  }

  @override
  removeDialog(String name) {
    if (listDialog.isEmpty) return;
    listDialog.removeWhere((element) => element.name == name);
    _streamDialogController.value = listDialog;
  }

  @override
  removeAllDialog() {
    listDialog.clear();
    _streamDialogController.value = listDialog;
  }

  @override
  removeLastDialog() {
    if (listDialog.isEmpty) return;
    listDialog.removeLast();
    _streamDialogController.value = listDialog;
  }
}
