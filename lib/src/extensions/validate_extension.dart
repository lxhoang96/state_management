import '../widgets/custom_textfield.dart';

const emailPattern =
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const passwordPattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
const idPattern = r'^([0-9]{9}|[0-9]{12}|[A-Z]{1}[0-9]{7})$';

const taxNumberPattern = r'^([0-9]{10}|[0-9\.\-\/]{13,14})$';
String phonePattern = r'^(0|84){1,2}?[0-9]{9}$';

extension ValidateInput on String {
  // ///  kiểm tra mật khẩu có 1 chữ hoa, 1 chữ thường 1 số và độ dài >=6
  // bool checkValidatePassword() {
  //   return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$')
  //       .hasMatch(this);
  // }

  // /// kiểm tra điều kiện nhập cmt 9 đến 13 ký tự
  // ///
  // ///  String pattern = r'^([0-9]{9}|[0-9]{12}|[A-Z]{1}[0-9]{7})$';
  // ///
  // ///  CMT 9 số hoặc CCCD 12 số hoặc Hộ chiếu 1 chữ cái in hoa và 7 số

  // bool checkValidateCmt() {
  //   String pattern = r'^([0-9]{9}|[0-9]{12}|[A-Z]{1}[0-9]{7})$';

  //   RegExp regExp = RegExp(pattern);
  //   return !regExp.hasMatch(this);
  // }

  // /// kiểm tra điều kiện nhập mã số thuế 10 đến 14 ký tự
  // ///
  // ///  String pattern = r'^(?:[+0]9)?[0-9\.\-\/]{10,14}$';
  // ///
  // ///  Mã số thuế 10 số với DN và 13 + '-' với cá nhân

  // bool checkValidateMst() {
  //   String pattern = r'^([0-9]{10}|[0-9\.\-\/]{13,14})$';

  //   RegExp regExp = RegExp(pattern);
  //   return !regExp.hasMatch(this);
  // }

  // /// kiểm tra điều kiện nhập số điện thoại 10 đến 11 ký tự
  // ///
  // /// String pattern = r'^(?:[+0]9)?[0-9]{10,11}$';
  // ///
  // /// Lỗi số điện thoại > 11 số
  // ///
  // /// Số điện thoại có 10 đến 11 số bắt đầu với 0 hoặc 84
  // bool checkValidatePhone() {
  //   String pattern = r'^(0|84){1,2}?[0-9]{9}$';
  //   RegExp regExp = RegExp(pattern);

  //   return !regExp.hasMatch(this);
  // }

  // /// kiểm tra điều kiện nhập email
  // bool checkValidateEmail() {
  //   RegExp regExp = RegExp(pattern);

  //   return !regExp.hasMatch(this);
  // }

  checkValidate(ValidateType type) {
    String pattern = r"^\s*$";
    switch (type) {
      case ValidateType.email:
        pattern = emailPattern;
        break;
      case ValidateType.id:
        pattern = idPattern;
        break;
      case ValidateType.tax:
        pattern = taxNumberPattern;
        break;
      case ValidateType.password:
        pattern = passwordPattern;
        break;
      case ValidateType.phone:
        pattern = phonePattern;
        break;
      default:
        break;
    }
    RegExp regExp = RegExp(pattern);
    return !regExp.hasMatch(this);
  }
}
