import 'package:base/src/interfaces/widget_interfaces.dart';
// import 'package:base/src/interfaces/widget_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

final class LoadingController implements LoadingInterface {
  static final instance = LoadingController._();
  LoadingController._();
  // final showing = InnerObserver<bool>(initValue: false);
  final showing = BehaviorSubject<bool>.seeded(false);
  final _defaultWidget = const Stack(
    alignment: Alignment.center,
    children:  [
      // SizedBox(
      //     width: 65,
      //     height: 65,
      //     child: CircularProgressIndicator(
      //       color: Colors.white,
      //     )),
      SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
    ],
  );

  Widget loadingWidget(Widget? child, {int autoCloseSec = 3}) {
    Future.delayed(Duration(seconds: autoCloseSec)).then((value) {
      closeLoading();
    });
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(child: child ?? _defaultWidget),
    );
  }

  @override
  closeLoading() {
    if (showing.value) {
      showing.value = false;
      debugPrint("Loading Off Screen");
    }
  }

  @override
  openLoading() {
    showing.value = true;
    debugPrint("Loading On Screen");
  }
}
