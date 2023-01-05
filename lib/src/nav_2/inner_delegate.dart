import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';
// final _innerKey = GlobalKey<NavigatorState>();

class InnerDelegateRouter extends RouterDelegate<HomeRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<HomeRoutePath> {
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  InnerDelegateRouter({required initInner}) {
    Global.setInitInnerRouter(initInner);
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Global.innerStream,
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
  Future<void> setNewRoutePath(HomeRoutePath homeRoutePath) async {
    if (!kIsWeb) {
      return;
    }
    if (homeRoutePath.isUnknown) {
      Global.showUnknownPage();
      return;
    }

    if (homeRoutePath.pathName != null || homeRoutePath.pathName != homePath) {
      Global.setInnerPagesForWeb(
          homeRoutePath.pathName!.split('/value:')[1].split('/'));
      return;
    }
    Global.showHomePage();
  }
}
