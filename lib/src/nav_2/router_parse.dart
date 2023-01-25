import 'package:base/src/nav_2/control_nav.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

/// update flow by path in Web
class HomeRouteInformationParser
    extends RouteInformationParser<RoutePathConfigure> {
  // final RouterList routerList;
  // HomeRouteInformationParser(this.routerList);

  @override
  Future<RoutePathConfigure> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return RoutePathConfigure.unKnown();
    }
    final uri = Uri.parse(routeInformation.location ?? '');

    if (uri.pathSegments.isEmpty) {
      return RoutePathConfigure.home();
    }

    return RoutePathConfigure.otherPage(routeInformation.location);
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePathConfigure configuration) {
    if (configuration.isUnknown) {
      return const RouteInformation(location: unknownPath);
    }
    if (configuration.isHomePage) return RouteInformation(location: homePath);
    if (configuration.isOtherPage) {
      return RouteInformation(location: configuration.pathName);
    }
    if (configuration.lostConnected) {
      return const RouteInformation(location: lostConnectedPath);
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
