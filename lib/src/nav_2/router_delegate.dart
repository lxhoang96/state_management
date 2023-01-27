import 'package:base/base_widget.dart';
import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_page.dart';
import 'nav_config.dart';

/// [RouterDelegate] for main flow.
class HomeRouterDelegate extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  final InitBinding? initBinding;
  final String? appIcon;
  final bool useLoading;
  final bool useSnackbar;
  final DecorationImage? backgroundImage;
  final bool isDesktop;
  final Map<String, InitPage> listPages;
  final String homeRouter;
  final List<Widget> globalWidgets;
  HomeRouterDelegate(
      {required this.listPages,
      required this.homeRouter,
      this.initBinding,
      this.appIcon,
      this.useLoading = true,
      this.useSnackbar = true,
      this.backgroundImage,
      this.globalWidgets = const [],
      this.isDesktop = true}) {
    final outerStream = ObserverCombined([Global.outerStream]);
    outerStream.value.listen((event) {
      pages = event[0];
      // update with [ChangeNotifier]
      notifyListeners();
    });
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<Page> pages = [];

  @override
  Widget build(BuildContext context) {
    return GlobalState(
        listPages: listPages,
        homeRouter: homeRouter,
        initBinding: initBinding,
        appIcon: appIcon,
        isDesktop: isDesktop,
        useLoading: useLoading,
        useSnackbar: useSnackbar,
        backgroundImage: backgroundImage,
        globalWidgets: globalWidgets,
        child: pages.isNotEmpty
            ? Navigator(
                key: navigatorKey,
                pages: pages.toList(),
                // transitionDelegate: ,
                onPopPage: (route, result) {
                  if (!route.didPop(result)) {
                    return false;
                  }
                  Global.pop();
                  notifyListeners();

                  return true;
                })
            : const SizedBox());
  }

  @override
  RoutePathConfigure get currentConfiguration {
    if (pages.length > 1) {
      return RoutePathConfigure.otherPage(Global.getPath());
    }
    if (Global.getCurrentRouter() == unknownPath) {
      return RoutePathConfigure.unKnown();
    }
    return RoutePathConfigure.home();
  }

  @override
  Future<void> setNewRoutePath(RoutePathConfigure configuration) async {
    if (!kIsWeb) {
      notifyListeners();
      return;
    }
    if (configuration.isUnknown) {
      Global.showUnknownPage();
      notifyListeners();
      return;
    }
    if (configuration.lostConnected) {
      Global.showLostConnectedPage();
      notifyListeners();
      return;
    }

    if (configuration.pathName != null && configuration.pathName != homePath) {
      Global.setOuterPagesForWeb(
          configuration.pathName!.replaceAll('//', '/').split('/'));
      notifyListeners();
      return;
    }
    // Global.showHomePage();
    notifyListeners();
  }
}
