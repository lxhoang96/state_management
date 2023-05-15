import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../custom_router.dart';
import '../nav_config.dart';

/// [RouterDelegate] for main flow.
class HomeRouterDelegate extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  final InitBinding? initBinding;
  final Widget? loadingWidget;
  final bool useLoading;
  final bool useSnackbar;
  final DecorationImage? backgroundImage;
  final bool isDesktop;
  final Map<String, InitRouter> listPages;
  final String homeRouter;
  final List<Widget> globalWidgets;
  final List<NavigatorObserver> observers;
  HomeRouterDelegate( 
      {required this.listPages,
      required this.homeRouter,
      this.initBinding,
      this.loadingWidget,
      this.useLoading = true,
      this.useSnackbar = true,
      this.backgroundImage,
      this.globalWidgets = const [],
      this.observers = const [],
      this.isDesktop = true,
      Function(dynamic e, String currentRouter)? onNavigationError}) {
    MainState.instance.intialize(onNavigationError: onNavigationError);
    final outerStream = MainState.instance.outerStream;
    outerStream.stream.listen((value) {
      if (!listEquals(_pages, value)) {
        // _pages
        //   ..clear()
        //   ..addAll(value);
        _pages = value.toList();
        notifyListeners();
      }
    });
    final dialogStream = MainState.instance.dialogStream;

    dialogStream.stream.listen((value) {
      if (!listEquals(_dialogs, value)) {
        // _dialogs
        //   ..clear()
        //   ..addAll(value);
        _dialogs = value.toList();
        notifyListeners();
      }
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
        GlobalWidget(
          listPages: listPages,
          homeRouter: homeRouter,
          initBinding: initBinding,
          loadingWidget: loadingWidget,
          isDesktop: isDesktop,
          useLoading: useLoading,
          useSnackbar: useSnackbar,
          backgroundImage: backgroundImage,
          globalWidgets: globalWidgets,
          child: HeroControllerScope(
            controller: _mainHeroCtrl,
            child: _pages.isNotEmpty
                ? Navigator(
                    key: navigatorKey,
                    pages: _pages.toList(),
                    observers: observers,
                    // transitionDelegate: ,
                    onPopPage: (route, result) {
                      if (!route.didPop(result)) {
                        return false;
                      }
                      MainState.instance.pop();
                      notifyListeners();

                      return true;
                    })
                : const SizedBox(),
          ),
        ),
        HeroControllerScope(
          controller: _dialogHeroCtrl,
          child: _dialogs.isNotEmpty
              ? Navigator(
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
                )
              : const SizedBox(),
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
      MainState.instance.showUnknownRouter();
      notifyListeners();
      return;
    }
    if (configuration.lostConnected) {
      MainState.instance.showLostConnectedRouter();
      notifyListeners();
      return;
    }

    if (configuration.isHomePage) {
      MainState.instance.showHomeRouter();
      notifyListeners();
      return;
    }

    if (configuration.pathName != null) {
      MainState.instance.setOuterRoutersForWeb(
          configuration.pathName!.replaceAll('//', '/').split('/'));
      notifyListeners();
      return;
    }
    //MainState.instance.showHomePage();
    notifyListeners();
  }
}
