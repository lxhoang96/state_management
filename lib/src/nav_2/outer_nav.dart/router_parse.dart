import 'package:base/src/nav_2/control_nav.dart';
import 'package:flutter/material.dart';

import '../nav_config.dart';

/// update flow by path in Web
final class HomeRouteInformationParser
    extends RouteInformationParser<RoutePathConfigure> {
  // final RouterList routerList;
  // HomeRouteInformationParser(this.routerList);

  @override
  Future<RoutePathConfigure> parseRouteInformation(
      RouteInformation routeInformation) async {
    // if (routeInformation.uri.) {
    //   return RoutePathConfigure.unKnown();
    // }
    final uri = routeInformation.uri;

    if (uri.pathSegments.isEmpty || uri.path == homePath) {
      return RoutePathConfigure.home();
    }

    return RoutePathConfigure.otherPage(uri.path);
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePathConfigure configuration) {
    if (configuration.isUnknown) {
      return RouteInformation(uri: Uri.parse(unknownPath));
    }
    if (configuration.isHomePage) return RouteInformation(uri: Uri.parse(homePath));
    if (configuration.isOtherPage) {
      return RouteInformation(uri: Uri.parse(configuration.pathName??unknownPath));
    }
    if (configuration.lostConnected) {
      return RouteInformation(uri: Uri.parse(lostConnectedPath));
    }
    return null;
  }
}

// sealed class RouterList {
//   final List<String>? innerRoots;
//   // final List<String> outerPaths;
//   final List<MaterialPage> outerPages;
//   final Map<String, List<MaterialPage>>? innerPaths;

//   RouterList({required this.outerPages, this.innerRoots, this.innerPaths});
// }
