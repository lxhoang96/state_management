import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_page.dart';
import 'nav_config.dart';

class HomeRouterDelegate extends RouterDelegate<HomeRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<HomeRoutePath> {
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
      this.isDesktop = true});
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  // @override
  // HomeRoutePath get currentConfiguration {
  //   if (isError) return HomeRoutePath.unKnown();

  //   if (pathName == null) return HomeRoutePath.home();
  //   if (isInner) return HomeRoutePath.innerPage(pathName);
  //   return HomeRoutePath.outerPage(pathName);
  // }

  // pop() {}

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
      child: StreamBuilder(
          stream: Global.outerStream,
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
          }),
    );
  }

  @override
  Future<void> setNewRoutePath(HomeRoutePath homeRoutePath) async {
    if (!kIsWeb) {
      notifyListeners();
      return;
    }
    if (homeRoutePath.isUnknown) {
      Global.showUnknownPage();
      notifyListeners();
      return;
    }

    if (homeRoutePath.pathName != null || homeRoutePath.pathName != homePath) {
      // Global.setOuterPagesForWeb(homeRoutePath.pathName!.split('/'));
      notifyListeners();
      return;
    }
    Global.showHomePage();
    notifyListeners();
  }
}

// final examplePage = MaterialPage(child: child);

// class AppNav {
//   static const initRoute = '/';
//   static List<String> listActiveRouter = [];
//   static pushNamed(String page) {
//     listActiveRouter.add(page);
//   }

//   static back() {
//     listActiveRouter.removeLast();
//   }

//   static backAllandPushNamed(String page) {
//     listActiveRouter = [];
//     listActiveRouter.add(page);
//   }

//   // static
// }
