import 'package:base/src/nav_2/control_nav.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

class HomeRouteInformationParser extends RouteInformationParser<HomeRoutePath> {
  // final RouterList routerList;
  // HomeRouteInformationParser(this.routerList);

  @override
  Future<HomeRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return HomeRoutePath.unKnown();
    }
    final uri = Uri.parse(routeInformation.location ?? '');

    if (uri.pathSegments.isEmpty) {
      return HomeRoutePath.home();
    }


    return HomeRoutePath.otherPage(routeInformation.location);
  }

  @override
  RouteInformation? restoreRouteInformation(HomeRoutePath homeRoutePath) {
    if (homeRoutePath.isUnknown) {
      return const RouteInformation(location: unknownPath);
    }
    if (homeRoutePath.isHomePage) return const RouteInformation(location: homePath);
    if (homeRoutePath.isOtherPage) {
      return RouteInformation(location: homeRoutePath.pathName);
    }

    return null;
  }
}

class RouterList {
  final List<String>? innerRoots;
  // final List<String> outerPaths;
  final List<MaterialPage> outerPages;
  final Map<String, List<MaterialPage>>? innerPaths;

  RouterList({required this.outerPages, this.innerRoots, this.innerPaths});
}
