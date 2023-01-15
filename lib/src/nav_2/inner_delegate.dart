import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';
// final _innerKey = GlobalKey<NavigatorState>();

class InnerDelegateRouter extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  InnerDelegateRouter({required this.parentName, required initInner}) {
    Global.setInitInnerRouter(initInner);
  }
  final String parentName;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Global.innerStream(parentName),
        builder: (context, value) {
          if (value.data != null && value.data!.isNotEmpty) {
            return Navigator(
                key: navigatorKey,
                pages: value.data!.toList(),
                onPopPage: (route, result) {
                  if (!route.didPop(result)) return false;

                  Global.pop();

                  return true;
                });
          }
          return const SizedBox();
        });
  }

  @override
  Future<void> setNewRoutePath(RoutePathConfigure configuration) async {
    if (!kIsWeb) {
      return;
    }
    if (configuration.isUnknown) {
      Global.showUnknownPage();
      return;
    }

    if (configuration.pathName != null || configuration.pathName != homePath) {
      // Global.setInnerPagesForWeb(
      //     RoutePathConfigure.pathName!.split('/value:')[1].split('/'));
      return;
    }
    Global.showHomePage();
  }
}
