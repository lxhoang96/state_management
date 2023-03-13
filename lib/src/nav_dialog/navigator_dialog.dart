import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:flutter/material.dart';

class DialogNavigator implements DialogNavigatorInterfaces {
  // final List<MaterialPage> listDialog = [];

  /// The Navigator stack is updated with these stream
  /// [_streamDialogController] for dialog flow
  final _streamDialogController =
      InnerObserver<List<MaterialPage>>(initValue: []);

  InnerObserver<List<MaterialPage>> get dialogStream => _streamDialogController;

  @override
  showDialog({required Widget child, required String name}) {
    _streamDialogController.value.add(MaterialPage(
        child: child,
        // fullscreenDialog: true,
        maintainState: false,
        key: ValueKey(name),
        name: name));
    // _streamDialogController.value = listDialog;
    _streamDialogController.update();
  }

  @override
  removeDialog(String name) {
    if (_streamDialogController.value.isEmpty) return;
    _streamDialogController.value
        .removeWhere((element) => element.name == name);
    _streamDialogController.update();
  }

  @override
  removeAllDialog() {
    _streamDialogController.value.clear();
    _streamDialogController.update();
  }

  @override
  removeLastDialog() {
    if (_streamDialogController.value.isEmpty) return;
    _streamDialogController.value.removeLast();
    _streamDialogController.update();
  }
}
