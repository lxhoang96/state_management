import 'package:base/base_component.dart';
import 'package:flutter/material.dart';

class AppLoading {
  static final showing = Observer<bool>(initValue: false, autoClose: false);

  static Widget loadingWidget(String? image, {int autoCloseSec = 3}) {
    Future.delayed(Duration(seconds: autoCloseSec)).then((value) {
      closeLoading();
    });
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  color: Colors.white,
                )),
            SizedBox(
              width: 50,
              height: 50,
              child: image != null
                  ? Image.asset(image)
                  : const CircularProgressIndicator(), //AppImages.landingImg('icon_robot')
            )
          ],
        ),
      ),
    );
  }

  static Widget customLoading(Widget child, {int autoCloseSec = 3}) {
    Future.delayed(Duration(seconds: autoCloseSec)).then((value) {
      closeLoading();
    });
    return child;
  }

  static closeLoading() {
    if (showing.value) {
      showing.value = false;
      debugPrint("Loading Off Screen");
    }
  }

  static openLoading() {
    showing.value = true;
    debugPrint("Loading On Screen");
  }
}
