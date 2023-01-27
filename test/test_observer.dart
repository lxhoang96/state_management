import 'package:base/base_component.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Get router', () {
    final intObs = Observer(initValue: 0);
    expect(intObs.route, homePath);
  });
}
