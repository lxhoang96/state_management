import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/widget_interfaces.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


final class SnackBarController implements SnackbarInterface {
  static final instance = SnackBarController._();
  SnackBarController._();
  // final showSnackBar = InnerObserver(initValue: false);
  // Widget snackbar = const SizedBox();
  final snackbars = InnerObserver<List<Widget>>(initValue: []);

  @override
  showSnackbar(
      {required SnackBarStyle style,
      required String? message,
      required String title,
      Function()? onTap,
      int timeout = 3}) {
    // showSnackBar.value = true;

    final snackbar = Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: onTap != null
            ? HitTestBehavior.deferToChild
            : HitTestBehavior.translucent,
        // gestures: {
        //   AllowMultipleTap:
        //       GestureRecognizerFactoryWithHandlers<AllowMultipleTap>(
        //     () => AllowMultipleTap(),
        //     (AllowMultipleTap instance) {
        //       instance.onTap = onTap;
        //     },
        //   )
        // },
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    snackbars.value.add(snackbar);
    snackbars.update();
    Future.delayed(Duration(seconds: timeout)).then((value) {
      snackbars.value.remove(snackbar);
      snackbars.update();
    });
  }

  @override
  showCustomSnackbar({required Widget child, int timeout = 3}) {
    // snackbar = child;
    // showSnackBar.value = true;
    // Future.delayed(Duration(seconds: timeout))
    //     .then((value) => showSnackBar.value = false);

    snackbars.value.add(child);
    snackbars.update();
    Future.delayed(Duration(seconds: timeout)).then((value) {
      snackbars.value.remove(child);
      snackbars.update();
    });
  }
}

final class SnackBarStyle {
  const SnackBarStyle(this.backgroundColor, this.textColor);
  final Color backgroundColor;
  final Color textColor;

  SnackBarStyle.success()
      : backgroundColor = const Color.fromARGB(255, 75, 181, 67),
        textColor = Colors.white;
  SnackBarStyle.warning()
      : backgroundColor = const Color.fromARGB(255, 255, 204, 0),
        textColor = Colors.white;
  SnackBarStyle.failed()
      : backgroundColor = const Color(0xffee0033),
        textColor = Colors.white;
}

class AllowMultipleTap extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
