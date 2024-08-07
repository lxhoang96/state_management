import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_2/custom_router.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';

/// Delegate for nested navigation.
final class InnerDelegateRouter extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  final List<NavigatorObserver> observers;
  final Map<String, InitRouter> listPages;
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  InnerDelegateRouter({
    required String parentName,
    required this.listPages,
    required String initInner,
    this.observers = const [],
  }) {
    MainState.instance.setInitRouters(listPages);
    MainState.instance.setInitInnerRouter(initInner, parentName);
    final stream = MainState.instance.innerStream(parentName);
    stream?.stream.listen((value) {
      if (!listEquals(_pages, value)) {
        _pages = value.toList();
        notifyListeners();
      }
    });
  }

  List<Page> _pages = [];
  @override
  Widget build(BuildContext context) {
    if (_pages.isNotEmpty) {
      return Navigator(
          key: navigatorKey,
          pages: _pages.toList(),
          observers: observers,
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            MainState.instance.pop();

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
      MainState.instance.showUnknownRouter();
      return;
    }

    if (configuration.pathName != null || configuration.pathName != homePath) {
      //MainState.instance.setInnerPagesForWeb(
      //     RoutePathConfigure.pathName!.split('/value:')[1].split('/'));
      return;
    }
    MainState.instance.showHomeRouter();
  }
}
