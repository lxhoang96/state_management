import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/appnav_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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

  String get currentRouter => _currentRouter?.routerName ?? homePath;
  String? get parentRouter => _currentRouter?.parentName;

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

  /// Validates the router name and throws an exception if it is invalid.
  InitRouter _validateRouterName(String routerName) {
    if (!_initRouters.containsKey(routerName)) {
      throw Exception('Router not found: $routerName');
    }
    return _initRouters[routerName]!;
  }

  /// Validates the parent router and throws an exception if it is invalid.
  BaseRouter _validateParentRouter(String parentName) {
    final parentRouter = _outerRouters.getByName(parentName);
    if (parentRouter == null) {
      throw Exception('Parent router not found: $parentName');
    }
    return parentRouter;
  }

  /// Ensures the navigation stack is not empty before popping.
  void _ensureStackNotEmpty({String? parentName}) {
    if (parentName == null && _outerRouters.length <= 1) {
      throw Exception('Cannot pop: no backward router available.');
    }
  }

  /// Prevents circular references in the navigation stack.
  void _preventCircularReference(String routerName, {String? parentName}) {
    if (parentName == null) {
      if (_outerRouters.any((router) => router.routerName == routerName)) {
        throw Exception('Circular reference detected for router: $routerName');
      }
    } else {
      final parentRouter = _validateParentRouter(parentName);
      if (parentRouter.innerRouters.any((router) => router.routerName == routerName)) {
        throw Exception('Circular reference detected for router: $routerName in parent: $parentName');
      }
    }
  }

  /// Set routers will display in App
  void setInitRouters(Map<String, InitRouter> initRouters) {
    _initRouters.addAll(initRouters);
  }

  _updateOuter(BaseRouter router) {
    // O(n)
    _currentRouter = router;
    _streamOuterController.value = _outerRouters.getMaterialPage(); // O(n)
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
    _updateOuter(splashRouter);
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
    _updateOuter(unknownRouter);
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
    _updateOuter(homeRouter);
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
    _updateOuter(lostConnectedRouter);
  }

  void _updateRouterStack(BaseRouter newRouter, {String? parentName}) {
    if (parentName == null) {
      _outerRouters.add(newRouter);
      _updateOuter(newRouter );
    } else {
      final parentRouter = _outerRouters.getByName(parentName);
      if (parentRouter == null) {
        throw Exception('Parent router not found: $parentName');
      }
      parentRouter.innerRouters.add(newRouter);
      _streamInnerController[parentName]?.value =
          parentRouter.innerRouters.getMaterialPage();
    }
  }

  /// push a page
  @override
  void pushNamed(String routerName, {String? parentName, dynamic arguments}) {
    final initRouter = _validateRouterName(routerName);
    _preventCircularReference(routerName, parentName: parentName);
    _removeDuplicate(routerName, parentName: parentName);
    final newRouter = initRouter.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);
    _currentRouter = newRouter;
    _updateRouterStack(newRouter, parentName: parentName);
  }

  /// remove last page and replace this with new one
  @override
  void popAndReplaceNamed(String routerName,
      {String? parentName, dynamic arguments}) {
    final initRouter = _validateRouterName(routerName);
    // _ensureStackNotEmpty(parentName: parentName);
  
    final newRouter = initRouter.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);
    if (parentName == null) {
      if (_outerRouters.isEmpty) {
        throw Exception('No routers to replace in outer stack');
      }
      _outerRouters.removeLast();
      _updateRouterStack(newRouter);
    } else {
      final parentRouter = _outerRouters.getByName(parentName);
      if (parentRouter == null) {
        throw Exception('Parent router not found: $parentName');
      }
      parentRouter.popAndAddInner(newRouter);
      _streamInnerController[parentName]?.value =
          parentRouter.innerRouters.getMaterialPage();
    }
  }

  /// remove all and add a page
  @override
  void popAllAndPushNamed(String routerName,
      {String? parentName, dynamic arguments}) {
    final initRouter = _validateRouterName(routerName);
    _preventCircularReference(routerName, parentName: parentName);
     final newRouter = initRouter.toBaseRouter(routerName,
        arguments: arguments, parentName: parentName);
    if (parentName == null) {
      _outerRouters.clear();
      _updateRouterStack(newRouter);
      _streamInnerController.forEach((key, value) => value.dispose());
      _streamInnerController.clear();
    } else {
      final parentRouter = _outerRouters.getByName(parentName);
      if (parentRouter == null) {
        throw Exception('Parent router not found: $parentName');
      }
      parentRouter.popAllAndPushInner(newRouter);
      _streamInnerController[parentName]?.value =
          parentRouter.innerRouters.getMaterialPage();
    }
  }

  /// remove last page
  @override
  void pop() {
    _ensureStackNotEmpty();
    // O(n)
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 router, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is inner routing but has only one inner router, solution: pop parent router
    final parentName = _currentRouter?.parentName;
    // case 1:

    final lastParent = _outerRouters.last;
    // case 2:
    if (parentName != null && lastParent.pop()) {
      // O(n)
      _currentRouter = lastParent.innerRouters.last;
      _streamInnerController[parentName]?.value =
          lastParent.innerRouters.getMaterialPage();
      return;
    }
    // case 3:
    final oldPage = _outerRouters.removeLast();
    _updateOuter(_outerRouters.last); // O(n)
    // _streamInnerController[oldPage.routerName]?.dispose();
    final oldInner = _streamInnerController.remove(oldPage.routerName);
    oldInner?.dispose();
  }

  /// remove several pages until page with routerName
  @override
  void popUntil(String routerName, {String? parentName}) {
    _validateRouterName(routerName);
    _ensureStackNotEmpty(parentName: parentName);
    // O(n)
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 router, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is outer routing.
    // case 1:

    final lastParent = _outerRouters.last;
    
    
    // case 2:
    if (parentName != null &&
        _outerRouters.getByName(parentName)?.popUntil(routerName) == true) {
      // O(n)
    
    
      _currentRouter = lastParent.innerRouters.last;
      _streamInnerController[parentName]?.value =
          lastParent.innerRouters.getMaterialPage(); // O(n)
      return;
    }
    // case 3:
    _outerRouters.length = _outerRouters
            .indexWhere((element) => element.routerName == routerName) +
        1; // O(n)
    _updateOuter(_outerRouters.last); // O(n)
  }

  /// check a router is active or not
  bool checkActiveRouter(String routerName, {String? parentName}) {
    // O(n)
    if (routerName == '/') return true;

    if (parentName == null) {
      return _outerRouters.firstWhereOrNull(
              (element) => element.routerName == routerName) !=
          null; // O(n)
    }

    return _outerRouters
            .firstWhereOrNull((element) => element.routerName == parentName)
            ?.innerRouters
            .firstWhereOrNull((element) => element.routerName == routerName) !=
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
final newRouter = router.toBaseRouter(routerName, arguments: currentArguments);
      _outerRouters
          .add(newRouter);
    }
    _updateOuter(_outerRouters.last); // O(n)
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
    _streamInnerController[parentName]?.value =
        parentRouter.innerRouters.getMaterialPage(); // O(n)
  }

  getPath() {
    String path = '';
    for (var element in _outerRouters) {
      path += element.routerName;
    }
    return path;
  }
}
