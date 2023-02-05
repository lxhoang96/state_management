import 'package:base/src/base_component/base_controller.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test add controller', () {
    WidgetsFlutterBinding.ensureInitialized();
    final mainState = MainState.instance;
    mainState.add(TestController1());
    expect(mainState.find<TestController1>() == TestController1(), true);
    expect(() => mainState.find<TestController2>(), throwsA(isA<Exception>()));
  });

  test('add new controller', () {
    WidgetsFlutterBinding.ensureInitialized();
    final mainState = MainState.instance;
    final test1Ctrl = mainState.add(TestController1());
    final test1NewCtrl = mainState.addNew(TestController1());
    expect(identical(test1Ctrl, test1NewCtrl), false);
    expect(mainState.find<TestController1>(), test1NewCtrl);
  });

  test('remove a controller', () {
    WidgetsFlutterBinding.ensureInitialized();
    final mainState = MainState.instance;
    mainState.add(TestController1());
    // Global.remove<TestController2>();
    // expect(Global.find<TestController1>(), test1Ctrl);
    mainState.remove<TestController1>();
    Future.delayed(const Duration(seconds: 1)).then((value) => expect(
        () => mainState.find<TestController1>(), throwsA(isA<Exception>())));
  });
}

class TestController1 extends DefaultController {}

class TestController2 extends DefaultController {}

class TestController3 extends DefaultController {}

class TestController4 extends DefaultController {}
