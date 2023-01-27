import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

/// Delegate for nested navigation.
class InnerDelegateRouter extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  InnerDelegateRouter({required parentName, required initInner}) {
    Global.setInitInnerRouter(initInner);
    final stream = Global.innerStream(parentName);
    if (stream == null) return;
    final innerStream = ObserverCombined([stream]);
    innerStream.value.listen((event) {
      pages = event[0];
      // update with [ChangeNotifier]
      notifyListeners();
    });
  }

  List<Page> pages = [];
  @override
  Widget build(BuildContext context) {
    if (pages.isNotEmpty) {
      return Navigator(
          key: navigatorKey,
          pages: pages.toList(),
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            Global.pop();

            return true;
          });
    }
    return const SizedBox();
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
