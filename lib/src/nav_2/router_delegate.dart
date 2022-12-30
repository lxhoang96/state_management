import 'package:base/src/nav_2/router_parse.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

class HomeRouterDelegate extends RouterDelegate<HomeRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<HomeRoutePath> {
  // String? pathName;
  bool isError = false;
  // String? innerRoot;
  final RouterList routerList;

  HomeRouterDelegate(this.routerList);

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
    final pages = getListRouter();

    return Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          if (AppNav.pathName != null) {
            final listString = Uri.parse(AppNav.pathName!).pathSegments;
            if (listString.isNotEmpty) listString.removeLast();
            AppNav.pathName = listString.join();
          }
          isError = false;
          notifyListeners();

          return true;
        });
  }

  @override
  Future<void> setNewRoutePath(HomeRoutePath homeRoutePath) async {
    if (homeRoutePath.isUnknown) {
      AppNav.pathName = null;
      isError = true;
      return;
    }

    if (!homeRoutePath.isHomePage) {
      if (homeRoutePath.pathName != null) {
        AppNav.pathName = homeRoutePath.pathName;
        isError = false;
        return;
      } else {
        isError = true;
        return;
      }
    } else {
      AppNav.pathName = null;
    }
  }

  getListRouter() {
    if (AppNav.pathName != null &&
        routerList.innerRoots != null &&
        routerList.innerPaths != null) {
      return routerList.innerPaths![AppNav.pathName]!;
    }
    return routerList.outerPages;
  }
}

// final examplePage = MaterialPage(child: child);

class AppNav with ChangeNotifier {
  static String? pathName;
  static const initRoute = '/';
  static List<String> listActiveRouter = [];
  toPage(String name) {
    pathName = pathName;
    listActiveRouter = Uri.parse(pathName ?? '').pathSegments;
    notifyListeners();
  }
}
