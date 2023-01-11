import 'package:base/base_component.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_2/custom_page.dart';
import 'package:flutter/material.dart';

abstract class MainStateRepo {
  /// add an intance to App state
  T add<T>(T instance);

  void remove<T>();

  T find<T>();

  T addNew<T>(T instance);

  void addObs(Observer observer);

  /// Set pages will display in App
  void setInitPages(Map<String, InitPage> initPages);

  /// set Homepage
  void setHomeRouter(String routerName);

  /// set HomePage of nested pages if has any
  void setInitInnerRouter(String routerName);

  /// set UnknownPage on Web
  void setUnknownPage(String name);

  /// show UnknownPage
  void showUnknownPage();

  /// show HomePage
  void showHomePage();

  /// push a page
  void pushNamed(String routerName);

  /// remove last page
  void pop();

  /// remove several pages until page with routerName
  void popUntil(String routerName);

  /// remove last page and replace this with new one
  void popAndReplaceNamed(String routerName);

  /// remove all and add a page
  void popAllAndPushNamed(String routerName);

  /// only for web with path on browser
  void setOuterPagesForWeb(List<String> listRouter);

  /// only for web with path on browser
  void setInnerPagesForWeb({required parentName, List<String> listRouter = const []});

  String getCurrentRouter();
}

class MainState extends MainStateRepo {
  final Map<Type, InstanceRoute> _listCtrl = {};
  static final List<Observer> _listObserver = [];
  final _navApp = AppNav();

  Stream<List<MaterialPage<dynamic>>> get outerStream =>
      _navApp.outerStream;
  Stream<List<MaterialPage<dynamic>>>? innerStream(String parentName) =>
      _navApp.getInnerStream(parentName);

  @override
  T add<T>(T instance) {
    final controller = _listCtrl[T]?.instance;
    if (controller != null) {
      return controller as T;
    } else {
      _listCtrl[T] =
          InstanceRoute(route: _navApp.currentRouter, instance: instance);
      if (instance is BaseController) {
        instance.init();
      }
      debugPrint("Added Controller Type:$T");
    }

    return instance;
  }

  @override
  addNew<T>(instance) {
    remove<T>();

    _listCtrl[T] =
        InstanceRoute(route: _navApp.currentRouter, instance: instance);
    debugPrint("Added New Controller Type:$T");
    if (instance is BaseController) {
      instance.init();
    }
    return instance;
  }

  @override
  T find<T>() {
    // if (_listCtrl[T]?.instance != null) {
    //   return _listCtrl[T]?.instance as T;
    // }
    return _listCtrl[T]?.instance as T;
  }

  @override
  remove<T>() {
    final instance = _listCtrl[T]?.instance;
    if (instance != null) {
      if (instance is BaseController) {
        instance.dispose();
      }
      _listCtrl.remove(instance);
      debugPrint("Removed Controller Type:$T");
    }
  }

  _removeByInstance(InstanceRoute instanceInput) {
    final result = !_navApp.checkActiveRouter(instanceInput.route);
    if (result) {
      final instance = instanceInput.instance;
      if (instance is BaseController) {
        instance.dispose();
      }
    }
    return result;
  }

  void _autoRemoveCtrl() {
    _listCtrl.removeWhere((key, value) {
      final result = _removeByInstance(value);
      if (result) {
        debugPrint("Removed Controller Type:$key");
      }
      return result;
    });
    debugPrint('After deleted: ${_listCtrl.length}');
  }

  void _autoRemoveObs() {
    _listObserver.removeWhere((element) {
      if (element.route == null) return false;
      final result = !_navApp.checkActiveRouter(element.route!);
      if (result) {
        debugPrint('Closing $element obs!');
        element.dispose();
      }
      return result;
    });
  }

  @override
  void addObs(Observer observer) {
    _listObserver.add(observer);
  }

  void _autoRemove() {
    _autoRemoveCtrl();
    _autoRemoveObs();
  }

  @override
  void pop() {
    _navApp.pop();
    _autoRemove();
  }

  @override
  void popAllAndPushNamed(String routerName) {
    _navApp.popAllAndPushNamed(routerName);
    _autoRemove();
  }

  @override
  void popAndReplaceNamed(String routerName) {
    _navApp.popAndReplaceNamed(routerName);
    _autoRemove();
  }

  @override
  void popUntil(String routerName) {
    _navApp.popUntil(routerName);
    _autoRemove();
  }

  @override
  void pushNamed(String routerName) =>
      _navApp.pushNamed(routerName);

  @override
  void setHomeRouter(String routerName) => _navApp.setHomeRouter(routerName);

  @override
  void setInitInnerRouter(String routerName) =>
      _navApp.setInitInnerRouter(routerName);

  @override
  void setInitPages(Map<String, InitPage> initPages) =>
      _navApp.setInitPages(initPages);

  @override
  void setInnerPagesForWeb({required parentName, List<String> listRouter = const []}) =>
      _navApp.setInnerPagesForWeb(parentName: parentName, listRouter: listRouter);

  @override
  void setOuterPagesForWeb(List<String> listRouter) =>
      _navApp.setOuterPagesForWeb(listRouter);

  @override
  void setUnknownPage(String name) => _navApp.setUnknownPage(name);

  @override
  void showHomePage() => _navApp.showHomePage();

  @override
  void showUnknownPage() => _navApp.showUnknownPage();

  @override
  getCurrentRouter() => _navApp.currentRouter;
}

class InstanceRoute<T> {
  final String route;
  final T instance;

  InstanceRoute({required this.route, required this.instance});
}

final Global = MainState();
