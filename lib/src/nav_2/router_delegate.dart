import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

class HomeRouterDelegate extends RouterDelegate<HomeRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<HomeRoutePath> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  // @override
  // HomeRoutePath get currentConfiguration {
  //   if (isError) return HomeRoutePath.unKnown();

  //   if (pathName == null) return HomeRoutePath.home();
  //   if (isInner) return HomeRoutePath.innerPage(pathName);
  //   return HomeRoutePath.outerPage(pathName);
  // }

  // pop() {}

  @override
  Widget build(BuildContext context) {
    return GlobalState(
      child: StreamBuilder(
        stream: Global.navApp.outerStream,
        builder: (context, value) => Navigator(
            key: navigatorKey,
            pages: value.data ?? [],
            onPopPage: (route, result) {
              if (!route.didPop(result)) return false;

              Global.navApp.pop();

              return true;
            }),
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(HomeRoutePath homeRoutePath) async {
    if (!kIsWeb) {
      notifyListeners();
      return;
    }
    if (homeRoutePath.isUnknown) {
      Global.navApp.showUnknownPage();
      notifyListeners();
      return;
    }

    if (homeRoutePath.pathName != null || homeRoutePath.pathName != homePath) {
      Global.navApp.setOuterPagesForWeb(homeRoutePath.pathName!.split('/'));
      notifyListeners();
      return;
    }
    Global.navApp.showHomePage();
    notifyListeners();
  }
}

// final examplePage = MaterialPage(child: child);

// class AppNav {
//   static const initRoute = '/';
//   static List<String> listActiveRouter = [];
//   static pushNamed(String page) {
//     listActiveRouter.add(page);
//   }

//   static back() {
//     listActiveRouter.removeLast();
//   }

//   static backAllandPushNamed(String page) {
//     listActiveRouter = [];
//     listActiveRouter.add(page);
//   }

//   // static
// }
