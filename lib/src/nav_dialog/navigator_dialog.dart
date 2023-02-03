import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DialogNavigator implements DialogNavigatorInterfaces {
  final List<MaterialPage> listDialog = [];

  /// The Navigator stack is updated with these stream
  /// [_streamDialogController] for dialog flow
  final _streamDialogController =
      BehaviorSubject<List<MaterialPage>>.seeded([]);

  Stream<List<MaterialPage>> get dialogStream => _streamDialogController.stream;

  @override
  showDialog({required Widget child, required String name}) {
    listDialog.add(MaterialPage(
        child: child,
        // fullscreenDialog: true,
        maintainState: false,
        key: ValueKey(name),
        name: name));
    _streamDialogController.add(listDialog);
  }

  @override
  removeDialog(String name) {
    if (listDialog.isEmpty) return;
    listDialog.removeWhere((element) => element.name == name);
    _streamDialogController.add(listDialog);
  }

  @override
  removeAllDialog() {
    listDialog.clear();
    _streamDialogController.add(listDialog);
  }

  @override
  removeLastDialog() {
    if (listDialog.isEmpty) return;
    listDialog.removeLast();
    _streamDialogController.add(listDialog);
  }
}
