import 'package:base/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

abstract interface class LoadingInterface {
  void closeLoading();

  void openLoading();
}



abstract interface class SnackbarInterface {
  void showSnackbar(
      {required SnackBarStyle style,
      required String? message,
      required String title,
      Function? onTap,
      int timeout = 3});

  void showCustomSnackbar({required Widget child, int timeout = 3});
}
