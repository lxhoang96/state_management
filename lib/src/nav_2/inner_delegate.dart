import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

class InnerDelegateRouter extends RouterDelegate<HomeRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<HomeRoutePath> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Global.navApp.innerStream,
      builder: (context, value) => Navigator(
          key: navigatorKey,
          pages: value.data ?? [],
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            Global.navApp.pop();

            return true;
          }),
    );
  }

  @override
  Future<void> setNewRoutePath(HomeRoutePath homeRoutePath) async {
    if (!kIsWeb) {
      return;
    }
    if (homeRoutePath.isUnknown) {
      Global.navApp.showUnknownPage();
      return;
    }

    if (homeRoutePath.pathName != null || homeRoutePath.pathName != homePath) {
      Global.navApp.setInnerPagesForWeb(
          homeRoutePath.pathName!.split('/value:')[1].split('/'));
      return;
    }
    Global.navApp.showHomePage();
  }
}
