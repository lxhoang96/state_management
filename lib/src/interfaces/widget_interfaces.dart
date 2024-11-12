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
      Function()? onTap,
      required int timeout});

  void showCustomSnackbar({required Widget child, required int timeout});
}
