import 'package:base/src/base_component/light_observer.dart';
import 'package:flutter/material.dart';

abstract class LoadingInterface {
  void closeLoading();

  void openLoading();
}

class AppLoading {
  static final LoadingInterface _controller = LoadingController.instance;
  static closeLoading() => _controller.closeLoading();

  static openLoading() => _controller.openLoading();
}

class LoadingController extends LoadingInterface {
  static final instance = LoadingController._();
  LoadingController._();
  final showing = InnerObserver<bool>(false);
  final _defaultWidget = Stack(
    alignment: Alignment.center,
    children: const [
      SizedBox(
          width: 65,
          height: 65,
          child: CircularProgressIndicator(
            color: Colors.white,
          )),
      SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(), //AppImages.landingImg('icon_robot')
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
