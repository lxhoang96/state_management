import 'package:flutter/material.dart';

class BaseSizes {
  static final instance = BaseSizes._();
  BaseSizes._();
  late final double _deviceWidth;
  late final double _deviceHeight;
  init(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
  }

  double get deviceWidth => _deviceWidth;
  double get deviceHeight => _deviceHeight;
}
