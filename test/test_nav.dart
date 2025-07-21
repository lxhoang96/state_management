import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_2/custom_router.dart';

void main() {
  group('AppNav Tests', () {
    late AppNav appNav;
        final testArg = {'test': 'argument'};

    setUp(() {
      appNav = AppNav();
      appNav.setInitRouters({
        '/home': InitRouter(widget: () => const SizedBox()),
        '/about': InitRouter(widget: () => const SizedBox(), argumentNav: testArg),
        '/contact': InitRouter(widget: () => const SizedBox()),
        '/splash': InitRouter(widget: () => const SizedBox()),
        '/lostConnection': InitRouter(widget: () => const SizedBox()),
        '/profile': InitRouter(widget: () => const SizedBox()),
        '/settings': InitRouter(widget: () => const SizedBox()),
        '/details': InitRouter(widget: () => const SizedBox()),
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
    
    test('goSplashScreen sets the splash screen as the only router', () {
      appNav.pushNamed('/about');
      appNav.pushNamed('/contact');
      appNav.goSplashScreen('/splash');
      expect(appNav.currentRouter, '/splash');
      expect(appNav.checkActiveRouter('/about'), false);
      expect(appNav.checkActiveRouter('/contact'), false);
    });
    
    test('showHomeRouter resets to the home router', () {
      appNav.pushNamed('/about');
      appNav.pushNamed('/contact');
      appNav.showHomeRouter();
      expect(appNav.currentRouter, '/home');
      expect(appNav.checkActiveRouter('/about'), false);
      expect(appNav.checkActiveRouter('/contact'), false);
    });
    
    test('setLostConnectedRouter and showLostConnectedRouter work correctly', () {
      appNav.setLostConnectedRouter('/lostConnection');
      appNav.showLostConnectedRouter();
      expect(appNav.currentRouter, '/lostConnected');
    });
    
    test('setOuterRoutersForWeb sets the navigation stack based on path list', () {
      appNav.setOuterRoutersForWeb(['/home', '/about', '/contact']);
      expect(appNav.currentRouter, '/contact');
      expect(appNav.checkActiveRouter('/home'), true);
      expect(appNav.checkActiveRouter('/about'), true);
    });
    
    test('setOuterRoutersForWeb handles paths without leading slash', () {
      appNav.setOuterRoutersForWeb(['home', 'about', 'contact']);
      expect(appNav.currentRouter, '/contact');
    });
    
    test('setOuterRoutersForWeb shows home router for default', () {
      appNav.setOuterRoutersForWeb(['/contact']);
      expect(appNav.currentRouter, '/contact');
    });
    
    test('getPath returns the complete path of current navigation stack', () {
      appNav.pushNamed('/about');
      appNav.pushNamed('/contact');
      expect(appNav.getPath(), '/home/about/contact');
    });

    group('Nested Navigation Tests', () {
      setUp(() {
        appNav = AppNav();
        appNav.setInitRouters({
          '/home': InitRouter(widget: () => const SizedBox()),
          '/about': InitRouter(widget: () => const SizedBox()),
          '/contact': InitRouter(widget: () => const SizedBox()),
          '/profile': InitRouter(widget: () => const SizedBox()),
          '/settings': InitRouter(widget: () => const SizedBox()),
          '/details': InitRouter(widget: () => const SizedBox()),
        });
        appNav.setHomeRouter('/home');
      });
      
      test('setInitInnerRouter initializes nested navigation', () {
        appNav.pushNamed('/profile');
        appNav.setInitInnerRouter('/settings', '/profile');
        expect(appNav.currentRouter, '/settings');
        expect(appNav.parentRouter, '/profile');
      });
      
      test('pushNamed with parentName adds nested router', () {
        appNav.pushNamed('/profile');
        appNav.pushNamed('/settings', parentName: '/profile');
        expect(appNav.currentRouter, '/settings');
        expect(appNav.parentRouter, '/profile');
      });
      
      test('pop with nested navigation removes inner router first', () {
        appNav.pushNamed('/profile');
        appNav.pushNamed('/settings', parentName: '/profile');
        appNav.pushNamed('/details', parentName: '/profile');
        appNav.pop();
        expect(appNav.currentRouter, '/settings');
        expect(appNav.parentRouter, '/profile');
      });
      
      test('popUntil with nested navigation works correctly', () {
        appNav.pushNamed('/profile');
        appNav.pushNamed('/settings', parentName: '/profile');
        appNav.pushNamed('/details', parentName: '/profile');
        appNav.popUntil('/settings', parentName: '/profile');
        expect(appNav.currentRouter, '/settings');
        expect(appNav.parentRouter, '/profile');
      });
      
      test('setInnerRoutersForWeb sets nested routers from path list', () {
        appNav.pushNamed('/profile');
        appNav.setInnerRoutersForWeb(
          parentName: '/profile', 
          listRouter: ['/settings', '/details']
        );
        expect(appNav.checkActiveRouter('/settings', parentName: '/profile'), true);
        expect(appNav.checkActiveRouter('/details', parentName: '/profile'), true);
      });
    });

    test('navigationArg returns current router argument', () {
      appNav.pushNamed('/about');
      expect(appNav.navigationArg, testArg);
    });
    
    test('currentArguments returns current router argument', () {
      appNav.pushNamed('/about', arguments: testArg);
      expect(appNav.currentArguments, testArg);
    });

    test('popAllAndPushNamed clears inner routers', () {
      appNav.pushNamed('/profile');
      appNav.pushNamed('/settings', parentName: '/profile');
      appNav.popAllAndPushNamed('/contact');
      expect(appNav.currentRouter, '/contact');
      expect(appNav.checkActiveRouter('/profile'), false);
      expect(appNav.checkActiveRouter('/settings', parentName: '/profile'), false);
    });
  });
}
