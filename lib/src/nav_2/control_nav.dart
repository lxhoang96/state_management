import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/appnav_interfaces.dart';
import 'package:flutter/material.dart';
import 'custom_router.dart';

String homePath = '/';
const unknownPath = '/unknown';
const lostConnectedPath = '/lostConnected';

/// This is the place you can controll your app flow with Navigation 2.0
/// [AppNav] have to be used with [HomeRouterDelegate],
/// [HomeRouteInformationParser] and [InnerDelegateRouter]
/// for controlling your entire app.
///
final class AppNav implements AppNavInterfaces {
  /// UnknownRouter can be update during app, so you can show different page
  /// for each unknownRouter.
  BaseRouter unknownRouter =
      BaseRouter(routerName: unknownPath, widget: () => Container());

  /// this is HomeRouter which will show when you open the app.
  BaseRouter homeRouter =
      BaseRouter(routerName: homePath, widget: () => const SizedBox());
  late final BaseRouter lostConnectedRouter;

  /// The Navigator stack is updated with these stream
  /// [_streamOuterController] for main flow and [_streamInnerController] for nested stack
  final _streamOuterController =
      InnerObserver<List<MaterialPage>>(initValue: []);
  final Map<String, InnerObserver<List<MaterialPage>>> _streamInnerController =
      {};

  /// This is routers will be shown in Navigator.
  final List<BaseRouter> _outerRouters = [];
  final Map<String, InitRouter> _initRouters = {};

  InnerObserver<List<MaterialPage>> get outerStream => _streamOuterController;
  InnerObserver<List<MaterialPage>>? getInnerStream(String routerName) =>
      _streamInnerController[routerName];

  /// currentRouter, this can be in main flow or nested flow
  BaseRouter? _currentRouter;
  BaseRouter? get currentRouter => _currentRouter;

  String get currentRouterName => _currentRouter?.routerName ?? homePath;
  String? get parentRouterName => _currentRouter?.parentName;

  /// argument when navigation.
  @override
  dynamic get navigationArg => _currentRouter?.argumentNav;

  @override
  dynamic get currentArguments => _currentRouter?.arguments;

  _removeDuplicate(String routerName, {String? parentName}) {
    // O(n)
    if (parentName == null) {
      _outerRouters
          .removeWhere((element) => element.routerName == routerName); // O(n)

      return;
    }
    final router = _outerRouters.getByName(parentName); // O(n)
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    router.innerRouters
        .removeWhere((element) => element.routerName == routerName); // O(n)
  }

  /// Set routers will display in App
  void setInitRouters(Map<String, InitRouter> initRouters) {
    _initRouters.addAll(initRouters);
  }

  updateOuter() {
    // O(n)
    _streamOuterController.value = _outerRouters.getMaterialPage(); // O(n)
  }

  updateInner(String parentName) {
    final parentRouter = _outerRouters.getByName(parentName);
    _streamInnerController[parentName]?.value =
        parentRouter?.innerRouters.getMaterialPage() ?? [];
  }

  /// set Splash screen
  void goSplashScreen(String routerName) {
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }

    final splashRouter = router.toBaseRouter(routerName); // O(n)
    _outerRouters
      ..clear()
      ..add(splashRouter);
    updateOuter();
    _streamInnerController.clear();
    _streamInnerController.forEach((key, value) {
      value.dispose();
    });
  }

  /// set Homepage
  void setHomeRouter(String routerName) {
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    homePath = routerName;
    homeRouter = router.toBaseRouter(homePath); // O(n)
    showHomeRouter();
  }

  /// set HomeRouter of nested routers if has any
  void setInitInnerRouter(String routerName, String parentName,
      {dynamic arguments}) {
    // O(n)
    final newPage = _initRouters[routerName];
    if (newPage == null) {
      throw Exception(['Can not find this router']);
    }
    final parentRouter = _outerRouters.getByName(parentName); // O(n)
    if (parentRouter == null) {
      throw Exception(['Parent is not in outer routing']);
    }

    if (parentRouter.innerRouters.isNotEmpty) return;

    final router = newPage.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);
    parentRouter.innerRouters.add(router);
    _currentRouter = router;
    _streamInnerController[parentRouter.routerName] =
        InnerObserver<List<MaterialPage>>(
      initValue: parentRouter.innerRouters.getMaterialPage(),
    );
  }

  /// set UnknownRouter on Web
  void setUnknownRouter(String name) {
    final router = _initRouters[name];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }

    unknownRouter = router.toBaseRouter(unknownPath);
  }

  /// show UnknownRouter
  void showUnknownRouter() {
    // O(n)
    _outerRouters
      ..clear()
      ..add(unknownRouter);
    _currentRouter = unknownRouter;
    updateOuter();
    _streamInnerController.forEach((key, value) {
      value.dispose();
    });
    _streamInnerController.clear();
  }

  /// show HomeRouter
  void showHomeRouter() {
    // O(n)
    _outerRouters
      ..clear()
      ..add(homeRouter);
    _currentRouter = homeRouter;
    updateOuter();
    _streamInnerController.clear();
    _streamInnerController.forEach((key, value) {
      value.dispose();
    });
  }

  void setLostConnectedRouter(String name) {
    // O(n)
    final router = _initRouters[name];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    lostConnectedRouter = router.toBaseRouter(lostConnectedPath);
  }

  void showLostConnectedRouter() {
    // O(n)
    _removeDuplicate(lostConnectedPath);
    _outerRouters.add(lostConnectedRouter);
    _currentRouter = lostConnectedRouter;
    updateOuter();
  }

  /// push a page
  @override
  void pushNamed<T>(String routerName, {String? parentName, dynamic arguments}) {
    // O(n)
    final initRouter = _initRouters[routerName];
    // check router exist
    if (initRouter == null) {
      throw Exception(['Can not find a router with this name']);
    }
    _removeDuplicate(routerName, parentName: parentName); // O(n)
    final router = initRouter.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);
    _currentRouter = router;
    // add new page to outer routing if it has no parent.
    if (parentName == null) {
      _outerRouters.add(router);
      // updateOuter();
      return;
    }
    // add new router to inner routing if it has parent.
    final parentRouter = _outerRouters.getByName(parentName); // O(n)
    parentRouter?.innerRouters.add(router);

    // _streamInnerController[parentName]?.value =
    //     parentRouter?.innerRouters.getMaterialPage() ?? []; // O(n)
    // updateInner(parentName, parentRouter);
  }

  /// remove last page
  @override
  void pop() {
    // O(n)
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 router, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is inner routing but has only one inner router, solution: pop parent router
    final parentName = _currentRouter?.parentName;
    // case 1:
    if (parentName == null && _outerRouters.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerRouters.last;
    // case 2:
    if (parentName != null && lastParent.pop()) {
      // O(n)
      _currentRouter = lastParent.innerRouters.last;
      // _streamInnerController[parentName]?.value =
      //     lastParent.innerRouters.getMaterialPage();
      updateInner(parentName);
      return;
    }
    // case 3:
    final oldPage = _outerRouters.removeLast();
    _currentRouter = _outerRouters.last;
    updateOuter(); // O(n)
    // _streamInnerController[oldPage.routerName]?.dispose();
    final oldInner = _streamInnerController.remove(oldPage.routerName);
    oldInner?.dispose();
  }

  /// remove several pages until page with routerName
  @override
  void popUntil(String routerName, {String? parentName}) {
    // O(n)
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 router, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is outer routing.
    // case 1:
    if (parentName == null && _outerRouters.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerRouters.last;
    // case 2:
    if (parentName != null &&
        _outerRouters.getByName(parentName)?.popUntil(routerName) == true) {
      // O(n)
      _currentRouter = lastParent.innerRouters.last;
      // _streamInnerController[parentName]?.value =
      //     lastParent.innerRouters.getMaterialPage(); // O(n)
      updateInner(parentName);
      return;
    }
    // case 3:
    _outerRouters.length = _outerRouters
            .indexWhere((element) => element.routerName == routerName) +
        1; // O(n)
    _currentRouter = _outerRouters.last;
    updateOuter(); // O(n)
  }

  /// remove last page and replace this with new one
  @override
  void popAndReplaceNamed<T>(String routerName,
      {String? parentName, dynamic arguments}) {
    // O(n)
    final newPage = _initRouters[routerName];
    // check if new page exist
    if (newPage == null) {
      throw Exception(['Can not find a page with this name']);
    }

    if (parentName == null && _outerRouters.isEmpty) {
      throw Exception(['Can not pop: no backward router']);
    }

    if (parentName != null) {
      final lastParent = _outerRouters.getByName(parentName);
      if (lastParent == null) {
        throw Exception(['Parent not in stack']);
      }
      final childRouter = newPage.toBaseRouter(routerName,
          arguments: arguments, parentName: parentName);
      lastParent.popAndAddInner(childRouter); // O(n)

      _currentRouter = childRouter;
      // _streamInnerController[parentName]?.value =
      //     lastParent.innerRouters.getMaterialPage(); // O(n)
      // updateInner(parentName, lastParent);
    }
    final oldLast = _outerRouters.removeLast();
    final newRouter = newPage.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);
    _outerRouters.add(newRouter);

    _currentRouter = _outerRouters.last;
    // updateOuter(); // O(n)
    _streamInnerController[oldLast.routerName]?.dispose();
    _streamInnerController.remove(oldLast.routerName);
  }

  /// remove all and add a page
  @override
  void popAllAndPushNamed<T>(String routerName,
      {String? parentName, dynamic arguments}) {
    // O(n)
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    final newPage = router.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);

    if (parentName != null) {
      final lastParent = _outerRouters.getByName(parentName);
      if (lastParent == null) {
        throw Exception(['Parent not in stack']);
      }
      final childRouter = newPage;
      lastParent.popAllAndPushInner(childRouter); // O(n)
      _currentRouter = childRouter;
      // _streamInnerController[parentName]?.value =
      //     lastParent.innerRouters.getMaterialPage(); // O(n)
      // updateInner(parentName, lastParent);
      return;
    }

    _outerRouters
      ..clear()
      ..add(newPage);
    _currentRouter = newPage;
    updateOuter(); // O(n)
    _streamInnerController.forEach((key, value) {
      value.dispose();
    }); // O(n)
    _streamInnerController.clear();
  }

  /// check a router is active or not
  bool checkActiveRouter(String routerName, {String? parentName}) {
    // O(n)
    if (routerName == '/') return true;

    if (parentName == null) {
      return _outerRouters.getByName(routerName) != null; // O(n)
    }

    return _outerRouters
            .getByName(parentName)
            ?.innerRouters
            .getByName(routerName) !=
        null; // O(n)
  }

  /// only for web with path on browser
  void setOuterRoutersForWeb(List<String> listRouter) {
    // O(n)
    listRouter.removeWhere((element) => element == '');
    _outerRouters.clear();
    for (var routerName in listRouter) {
      // O(n)
      if (!routerName.startsWith('/')) {
        routerName = '/$routerName';
      }
      final router = _initRouters[routerName];
      if (router == null) {
        _outerRouters
          ..clear()
          ..add(unknownRouter);
        return;
      }

      _outerRouters
          .add(router.toBaseRouter(routerName, arguments: currentArguments));
    }
    updateOuter(); // O(n)
  }

  /// only for web with path on browser
  void setInnerRoutersForWeb(
      // O(n)
      {required String parentName,
      List<String> listRouter = const [],
      dynamic arguments}) {
    final parentRouter = _outerRouters.getByName(parentName); // O(n)
    if (parentRouter == null) return;
    for (var routerName in listRouter) {
      // O(n)
      final router = _initRouters[routerName];
      if (router == null) {
        return;
      }

      parentRouter.addInner(router.toBaseRouter(routerName,
          arguments: arguments, parentName: parentName));
    }
    // _streamInnerController[parentName]?.value =
    //     parentRouter.innerRouters.getMaterialPage(); // O(n)
    updateInner(parentName);
  }

  getPath() {
    String path = '';
    for (var element in _outerRouters) {
      path += element.routerName;
    }
    return path;
  }
}
