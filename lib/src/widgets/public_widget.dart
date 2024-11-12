import 'package:base/src/interfaces/widget_interfaces.dart';
import 'package:base/src/widgets/custom_loading.dart';
import 'package:base/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

final class AppLoading {
  static final LoadingInterface _controller = LoadingController.instance;
  static closeLoading() => _controller.closeLoading();

  static openLoading() => _controller.openLoading();
}

final class AppSnackBar {
  static final SnackbarInterface _controller = SnackBarController.instance;
  static showSnackbar(
          {required SnackBarStyle style,
          required String? message,
          required String title,
          Function()? onTap,
          int timeout = 2}) =>
      _controller.showSnackbar(
          style: style,
          message: message,
          title: title,
          onTap: onTap,
          timeout: timeout);

  static showCustomSnackbar({required Widget child, int timeout = 2}) =>
      _controller.showCustomSnackbar(child: child, timeout: timeout);
}
