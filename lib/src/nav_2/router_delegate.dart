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
    final outerStream = ObserverCombined(
        [MainState.instance.outerStream, MainState.instance.dialogStream]);
    outerStream.value.listen((event) {
      _pages = event[0];
      _dialogs = event[1];
      // update with [ChangeNotifier]
      notifyListeners();
    });
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<Page> _pages = [];
  List<Page> _dialogs = [];

  final GlobalKey<NavigatorState> _dialogKey = GlobalKey<NavigatorState>();
  final _mainHeroCtrl = MaterialApp.createMaterialHeroController();
  final _dialogHeroCtrl = MaterialApp.createMaterialHeroController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlobalState(
            listPages: listPages,
            homeRouter: homeRouter,
            initBinding: initBinding,
            appIcon: appIcon,
            isDesktop: isDesktop,
            useLoading: useLoading,
            useSnackbar: useSnackbar,
            backgroundImage: backgroundImage,
            globalWidgets: globalWidgets,
            child: _pages.isNotEmpty
                ? HeroControllerScope(
                    controller: _mainHeroCtrl,
                    child: Navigator(
                        key: navigatorKey,
                        pages: _pages.toList(),
                        // transitionDelegate: ,
                        onPopPage: (route, result) {
                          if (!route.didPop(result)) {
                            return false;
                          }
                          MainState.instance.pop();
                          notifyListeners();

                          return true;
                        }),
                  )
                : const SizedBox()),
        if (_dialogs.isNotEmpty)
          HeroControllerScope(
                    controller: _dialogHeroCtrl,
            child: Navigator(
              key: _dialogKey,
              pages: _dialogs.toList(),
              onPopPage: (route, result) {
                if (!route.didPop(result)) {
                  return false;
                }
                MainState.instance.removeLastDialog();
                notifyListeners();
          
                return true;
              },
            ),
          ),
      ],
    );
  }

  @override
  RoutePathConfigure get currentConfiguration {
    if (_pages.length > 1) {
      return RoutePathConfigure.otherPage(MainState.instance.getPath());
    }
    if (MainState.instance.getCurrentRouter() == unknownPath) {
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
      MainState.instance.showUnknownPage();
      notifyListeners();
      return;
    }
    if (configuration.lostConnected) {
      MainState.instance.showLostConnectedPage();
      notifyListeners();
      return;
    }

    if (configuration.pathName != null && configuration.pathName != homePath) {
      MainState.instance.setOuterPagesForWeb(
          configuration.pathName!.replaceAll('//', '/').split('/'));
      notifyListeners();
      return;
    }
    // MainState.instance.showHomePage();
    notifyListeners();
  }
}
