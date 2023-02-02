import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:flutter/material.dart';



class DialogNavigator implements DialogNavigatorInterfaces{
  final List<MaterialPage> listDialog = [];

  @override
  showDialog({required Widget child, required DialogNameInterfaces name}) {
    listDialog.add(MaterialPage(
        child: child,
        fullscreenDialog: true,
        maintainState: false,
        name: name));
  }

  @override
  removeDialog(DialogNameInterfaces name) {
    if (listDialog.isEmpty) return;
    listDialog.removeWhere((element) => element.name == name);
  }

  @override
  removeAllDialog() {
    listDialog.clear();
  }
}
