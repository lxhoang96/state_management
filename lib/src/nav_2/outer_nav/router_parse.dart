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
    final uri = routeInformation.uri;

    // Validate the URI path
    if (uri.pathSegments.isEmpty || uri.path == homePath) {
      return RoutePathConfigure.home();
    }

    // Handle invalid or unexpected paths
    if (uri.path.isEmpty || uri.path == '/') {
      return RoutePathConfigure.unKnown();
    }

    // Log unexpected paths for debugging
    debugPrint('Parsing route: ${uri.path}');

    return RoutePathConfigure.otherPage(uri.path);
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePathConfigure configuration) {
    if (configuration.isUnknown) {
      debugPrint('Restoring unknown route');
      return RouteInformation(uri: Uri.parse(unknownPath));
    }
    if (configuration.isHomePage) {
      debugPrint('Restoring home route');
      return RouteInformation(uri: Uri.parse(homePath));
    }
    if (configuration.isOtherPage) {
      debugPrint('Restoring other page route: ${configuration.pathName}');
      return RouteInformation(uri: Uri.parse(configuration.pathName ?? unknownPath));
    }
    if (configuration.lostConnected) {
      debugPrint('Restoring lost connection route');
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
