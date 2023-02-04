import 'package:base/src/interfaces/appnav_interfaces.dart';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
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
class AppNav implements AppNavInterfaces {
  /// UnknownRouter can be update during app, so you can show different page
  /// for each unknownRouter.
  var unknownRouter =
      BaseRouter(routerName: unknownPath, widget: () => Container());

  /// this is HomeRouter which will show when you open the app.
  late final BaseRouter homeRouter;
  late final BaseRouter lostConnectedRouter;

  /// The Navigator stack is updated with these stream
  /// [_streamOuterController] for main flow and [_streamInnerController] for nested stack
  final _streamOuterController = BehaviorSubject<List<MaterialPage>>();
  final Map<String, BehaviorSubject<List<MaterialPage>>>
      _streamInnerController = {};

  /// This is routers will be shown in Navigator.
  final List<BaseRouter> _outerRouters = [];
  Map<String, InitRouter> _initRouters = {};

  Stream<List<MaterialPage>> get outerStream => _streamOuterController.stream;
  Stream<List<MaterialPage>>? getInnerStream(String routerName) =>
      _streamInnerController[routerName]?.stream;

  /// currentRouter, this can be in main flow or nested flow
  BaseRouter? _currentRouter;

  String get currentRouter => _currentRouter?.routerName ?? homePath;

  /// argument when navigation.
  dynamic get _arguments => _currentRouter?.argument;

  _removeDuplicate(String routerName, {String? parentName}) {
    if (parentName == null) {
      _outerRouters.removeWhere((element) => element.routerName == routerName);
      return;
    }
    final router = _outerRouters.getByName(parentName);
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }

    router.innerRouters
        .removeWhere((element) => element.routerName == routerName);
  }

  /// Set routers will display in App
  void setInitRouters(Map<String, InitRouter> initRouters) {
    _initRouters = initRouters;
  }

  _updateOuter() {
    _streamOuterController.add(_outerRouters.getMaterialPage());
  }

  /// set Homepage
  void setHomeRouter(String routerName) {
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    homePath = routerName;
    homeRouter = router.toBaseRouter(homePath);
    showHomeRouter();
  }

  /// set HomeRouter of nested routers if has any
  void setInitInnerRouter(String routerName) {
    final newPage = _initRouters[routerName];
    if (newPage == null || newPage.parentName == null) {
      throw Exception(
          ['Can not find this router or this router has no parent']);
    }
    final parentRouter = _outerRouters.getByName(newPage.parentName!);
    if (parentRouter == null) {
      throw Exception(['Parent is not in outer routing']);
    }

    if (parentRouter.innerRouters.isNotEmpty) return;

    final router = newPage.toBaseRouter(routerName);
    parentRouter.innerRouters.add(router);
    _currentRouter = router;
    _streamInnerController[parentRouter.routerName] =
        BehaviorSubject<List<MaterialPage>>.seeded(
            parentRouter.innerRouters.getMaterialPage());
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
    _outerRouters
      ..clear()
      ..add(unknownRouter);
    _currentRouter = unknownRouter;
    _updateOuter();
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  /// show HomeRouter
  void showHomeRouter() {
    _outerRouters
      ..clear()
      ..add(homeRouter);
    _currentRouter = homeRouter;
    _updateOuter();
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  void setLostConnectedRouter(String name) {
    final router = _initRouters[name];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    lostConnectedRouter = router.toBaseRouter(lostConnectedPath);
  }

  void showLostConnectedRouter() {
    _outerRouters.add(lostConnectedRouter);
    _currentRouter = lostConnectedRouter;
    _updateOuter();
  }

  @override

  /// push a page
  void pushNamed(String routerName) {
    final initRouter = _initRouters[routerName];
    // check router exist
    if (initRouter == null) {
      throw Exception(['Can not find a router with this name']);
    }
    _removeDuplicate(routerName, parentName: initRouter.parentName);
    final router = initRouter.toBaseRouter(routerName);
    _currentRouter = router;
    // add new page to outer routing if it has no parent.
    if (initRouter.parentName == null) {
      _outerRouters.add(router);
      _updateOuter();
      // final currentRouting = _streamOuterController.value;
      // currentRouting.add(router.getRouter());
      // _streamOuterController.add(currentRouting);
      return;
    }
    // add new router to inner routing if it has parent.
    final parentRouter = _outerRouters.getByName(initRouter.parentName!);
    parentRouter?.innerRouters.add(router);
    _streamInnerController[initRouter.parentName]
        ?.add(parentRouter?.innerRouters.getMaterialPage() ?? []);
  }

  /// remove last page
  @override
  void pop() {
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
      _currentRouter = lastParent.innerRouters.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerRouters.getMaterialPage());
      return;
    }
    // case 3:
    final oldPage = _outerRouters.removeLast();
    _currentRouter = _outerRouters.last;
    _updateOuter();
    _streamInnerController[oldPage.routerName]?.close();
  }

  /// remove several pages until page with routerName
  @override
  void popUntil(String routerName) {
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 router, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is outer routing.
    final parentName = _initRouters[routerName]?.parentName;
    // case 1:
    if (parentName == null && _outerRouters.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerRouters.last;
    // case 2:
    if (parentName != null &&
        _outerRouters.getByName(parentName)?.popUntil(routerName) == true) {
      _currentRouter = lastParent.innerRouters.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerRouters.getMaterialPage());
      return;
    }
    // case 3:
    _outerRouters.length = _outerRouters
            .indexWhere((element) => element.routerName == routerName) +
        1;
    _currentRouter = _outerRouters.last;
    _updateOuter();
  }

  /// remove last page and replace this with new one
  @override
  void popAndReplaceNamed(String routerName) {
    final newPage = _initRouters[routerName];
    // check if new page exist
    if (newPage == null) {
      throw Exception(['Can not find a page with this name']);
    }
    final parentName = newPage.parentName;

    if (parentName == null && _outerRouters.isEmpty) {
      throw Exception(['Can not pop: no backward router']);
    }

    if (parentName != null) {
      final lastParent = _outerRouters.last;
      if (lastParent.routerName != parentName) {
        throw Exception(['Last parent does not have this child']);
      }
      final childRouter = newPage.toBaseRouter(routerName);
      lastParent.popAndAddInner(childRouter);
      _currentRouter = childRouter;
      _streamInnerController[parentName]
          ?.add(lastParent.innerRouters.getMaterialPage());
      return;
    }
    final oldLast = _outerRouters.removeLast();
    _outerRouters.add(newPage.toBaseRouter(routerName));
    _currentRouter = _outerRouters.last;
    _updateOuter();
    _streamInnerController[oldLast.routerName]?.close();
  }

  /// remove all and add a page
  @override
  void popAllAndPushNamed(String routerName) {
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception(['Can not find a router with this name']);
    }
    if (router.parentName != null) {
      throw Exception(['Can not push an inner router: no parent found!']);
    }
    final newPage = router.toBaseRouter(routerName);

    _outerRouters
      ..clear()
      ..add(newPage);
    _currentRouter = newPage;
    _updateOuter();
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  /// check a router is active or not
  bool checkActiveRouter(String routerName) {
    if (routerName == '/') return true;
    final router = _initRouters[routerName];
    if (router?.parentName == null) {
      return _outerRouters.firstWhereOrNull(
              (element) => element.routerName == routerName) !=
          null;
    }
    return _outerRouters
            .firstWhereOrNull(
                (element) => element.routerName == router?.parentName)
            ?.innerRouters
            .firstWhereOrNull((element) => element.routerName == routerName) !=
        null;
  }

  /// only for web with path on browser
  void setOuterRoutersForWeb(List<String> listRouter) {
    listRouter.removeWhere((element) => element == '');
    _outerRouters.clear();
    for (var routerName in listRouter) {
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

      _outerRouters.add(router.toBaseRouter(routerName));
    }
    _updateOuter();
  }

  /// only for web with path on browser
  void setInnerRoutersForWeb(
      {required parentName, List<String> listRouter = const []}) {
    final parentRouter = _outerRouters.getByName(parentName);
    if (parentRouter == null) return;
    for (var routerName in listRouter) {
      final router = _initRouters[routerName];
      if (router == null) {
        return;
      }

      parentRouter.addInner(router.toBaseRouter(routerName));
    }
    _streamInnerController[parentName]
        ?.add(parentRouter.innerRouters.getMaterialPage());
  }

  getPath() {
    String path = '';
    for (var element in _outerRouters) {
      path += element.routerName;
    }
    return path;
  }

  @override
  getCurrentArgument() {
    return _arguments;
  }
}
