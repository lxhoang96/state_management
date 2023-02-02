import 'package:flutter/material.dart';

abstract class DialogNavigatorInterfaces {
  showDialog({required Widget child, required DialogNameInterfaces name});

  removeDialog(DialogNameInterfaces name);

  removeAllDialog();
}

abstract class DialogNameInterfaces {

}


