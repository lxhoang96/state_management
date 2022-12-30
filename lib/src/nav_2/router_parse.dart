import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'nav_config.dart';

class HomeRouteInformationParser extends RouteInformationParser<HomeRoutePath> {
  final RouterList routerList;
  HomeRouteInformationParser(this.routerList);

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
    final listPath = uri.pathSegments;
    final rootPath = listPath.elementAt(0);

    if (routerList.innerRoots != null &&
        routerList.innerRoots!.contains(rootPath)) {
      return HomeRoutePath.innerPage(routeInformation.location);
    }

    return HomeRoutePath.outerPage(routeInformation.location);
  }

  @override
  RouteInformation? restoreRouteInformation(HomeRoutePath homeRoutePath) {
    if (homeRoutePath.isUnknown) {
      return const RouteInformation(location: '/error');
    }
    if (homeRoutePath.isHomePage) return const RouteInformation(location: '/');
    if (homeRoutePath.isInnerPage || homeRoutePath.isOuterPage) {
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
