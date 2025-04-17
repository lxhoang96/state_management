import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_2/custom_router.dart';

void main() {
  group('AppNav Tests', () {
    late AppNav appNav;

    setUp(() {
      appNav = AppNav();
      appNav.setInitRouters({
        '/home': InitRouter(widget: () => const SizedBox()),
        '/about': InitRouter(widget: () => const SizedBox()),
        '/contact': InitRouter(widget: () => const SizedBox()),
      });
      appNav.setHomeRouter('/home');
    });

    test('pushNamed adds a new router to the stack', () {
      appNav.pushNamed('/about');
      expect(appNav.currentRouter, '/about');
    });

    test('pop removes the last router from the stack', () {
      appNav.pushNamed('/about');
      appNav.pop();
      expect(appNav.currentRouter, '/home');
    });

    test('popUntil removes routers until the specified router is reached', () {
      appNav.pushNamed('/about');
      appNav.pushNamed('/contact');
      appNav.popUntil('/about');
      expect(appNav.currentRouter, '/about');
    });

    test('popAndReplaceNamed replaces the last router with a new one', () {
      appNav.pushNamed('/about');
      appNav.popAndReplaceNamed('/contact');
      expect(appNav.currentRouter, '/contact');
    });

    test('popAllAndPushNamed clears the stack and adds a new router', () {
      appNav.pushNamed('/about');
      appNav.popAllAndPushNamed('/contact');
      expect(appNav.currentRouter, '/contact');
    });

    test('setHomeRouter updates the home router', () {
      appNav.setHomeRouter('/contact');
      expect(appNav.currentRouter, '/contact');
    });

    test('showUnknownRouter sets the unknown router', () {
      appNav.setUnknownRouter('/about');
      appNav.showUnknownRouter();
      expect(appNav.currentRouter, '/unknown');
    });

    test('checkActiveRouter verifies if a router is active', () {
      appNav.pushNamed('/about');
      expect(appNav.checkActiveRouter('/about'), true);
      expect(appNav.checkActiveRouter('/contact'), false);
    });
  });
}
