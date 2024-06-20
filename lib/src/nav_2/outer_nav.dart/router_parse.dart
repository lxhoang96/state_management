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
    if (routeInformation.uri.hasEmptyPath) {
      return RoutePathConfigure.unKnown();
    }
    final uri = routeInformation.uri;

    if (uri.pathSegments.isEmpty || routeInformation.uri.path == homePath) {
      return RoutePathConfigure.home();
    }

    return RoutePathConfigure.otherPage(routeInformation.uri.path);
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePathConfigure configuration) {
    if (configuration.isUnknown) {
      return RouteInformation(uri:Uri.parse(unknownPath));
    }
    if (configuration.isHomePage) return RouteInformation(uri: Uri.parse(homePath));
    if (configuration.isOtherPage) {
      return RouteInformation(uri: configuration.pathName != null? Uri.tryParse(configuration.pathName!): null);
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
