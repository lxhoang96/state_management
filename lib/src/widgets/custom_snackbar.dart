import 'package:base/src/base_component/light_observer.dart';
import 'package:base/src/theme/colors.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static final showSnackBar = InnerObserver(false);
  static Widget snackbar = const SizedBox();
  static defaultSnackBar(
      {required SnackBarStyle style,
      required String? message,
      required String title,
      String? fontFamily,
      Function? onTap}) {
    showSnackBar.value = true;
    Future.delayed(const Duration(seconds: 3))
        .then((value) => showSnackBar.value = false);
    snackbar = Material(
      color: Colors.transparent,
      child: Container(
        height: 60,
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
            children: [
              Text(
                title,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 16,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (message != null)
                Text(
                  message,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 12,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
