import 'package:base/base_widget.dart';
import 'package:flutter/foundation.dart';

class HandleException {
  static onTimeout() {
    debugPrint("On Timeout error");
    AppSnackBar.defaultSnackBar(
        style: SnackBarStyle.fail, title: 'Fail', message: "Request timeout");
  }

  static onSocket() {
    debugPrint("On Socket error");
    AppSnackBar.defaultSnackBar(
        style: SnackBarStyle.fail, title: 'Fail', message: "Socket exception");
  }

  static onHttp() {
    debugPrint("On Http error");
    AppSnackBar.defaultSnackBar(
        style: SnackBarStyle.fail, title: 'Fail', message: "Http exception");
  }

  static onUnhandled() {
    debugPrint("On Unhandled error");
    AppSnackBar.defaultSnackBar(
        style: SnackBarStyle.fail,
        title: 'Fail',
        message: "Unhandled exception");
  }
}
