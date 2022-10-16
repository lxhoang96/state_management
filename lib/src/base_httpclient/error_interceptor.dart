
import 'package:base/src/widgets/custom_snackbar.dart';

class HandleException {
  static onTimeout() {
    AppSnackBar.defaultSnackBar(style: SnackBarStyle.fail,title: 'Fail',message: "Request timeout");
  }

  static onSocket() {
    AppSnackBar.defaultSnackBar(style: SnackBarStyle.fail,title: 'Fail',message: "Socket exception");
  }

  static onHttp() {
    AppSnackBar.defaultSnackBar(style: SnackBarStyle.fail,title: 'Fail',message: "Http exception");
  }

  static onUnhandled() {
    AppSnackBar.defaultSnackBar(style: SnackBarStyle.fail,title: 'Fail',message: "Unhandled exception");
  }
}