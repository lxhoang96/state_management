import 'package:base/src/theme/colors.dart';
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


enum SnackBarStyle {
  success(AppColors.success, Colors.white),
  fail(AppColors.failed, Colors.white),
  warning(AppColors.warning, Colors.white),
  normal(Colors.white, AppColors.grey1);

  const SnackBarStyle(this.backgroundColor, this.textColor);
  final Color backgroundColor;
  final Color textColor;
}
