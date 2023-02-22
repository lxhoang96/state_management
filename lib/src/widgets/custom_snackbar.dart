import 'package:base/src/base_component/light_observer.dart';
import 'package:base/src/theme/colors.dart';
import 'package:flutter/material.dart';

abstract class SnackbarInterface {
  void showSnackbar(
      {required SnackBarStyle style,
      required String? message,
      required String title,
      Function? onTap,
      int timeout = 3});

  void showCustomSnackbar({required Widget child, int timeout = 3});
}

class SnackBarController extends SnackbarInterface {
  static final instance = SnackBarController._();
  SnackBarController._();
  final showSnackBar = InnerObserver(false);
  Widget snackbar = const SizedBox();
  @override
  showSnackbar(
      {required SnackBarStyle style,
      required String? message,
      required String title,
      Function? onTap,
      int timeout = 3}) {
    showSnackBar.value = true;
    Future.delayed(Duration(seconds: timeout))
        .then((value) => showSnackBar.value = false);
    snackbar = Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: style.backgroundColor.withAlpha(50),
              offset: const Offset(
                5.0,
                5.0,
              ),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
          color: style.backgroundColor.withOpacity(0.8),
        ),
        child: InkWell(
          onTap: () => onTap?.call(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (message != null)
                Text(
                  message,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  showCustomSnackbar({required Widget child, int timeout = 3}) {
    snackbar = child;
    showSnackBar.value = true;
    Future.delayed(Duration(seconds: timeout))
        .then((value) => showSnackBar.value = false);
  }
}

class AppSnackbar {
  static final SnackbarInterface _controller = SnackBarController.instance;
  static showSnackbar(
          {required SnackBarStyle style,
          required String? message,
          required String title,
          Function? onTap,
          int timeout = 3}) =>
      _controller.showSnackbar(
          style: style,
          message: message,
          title: title,
          onTap: onTap,
          timeout: timeout);

  static showCustomSnackbar({required Widget child, int timeout = 3}) =>
      _controller.showCustomSnackbar(child: child, timeout: timeout);
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
