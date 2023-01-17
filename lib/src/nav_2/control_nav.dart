import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import 'custom_page.dart';

String homePath = '/';
const unknownPath = '/unknown';

class AppNav {
  var unknownRouter =
      BasePage(routerName: unknownPath, widget: () => Container());
  var homeRouter = BasePage(routerName: homePath, widget: () => Container());
  final _streamOuterController = BehaviorSubject<List<MaterialPage>>();
  final Map<String, BehaviorSubject<List<MaterialPage>>>
      _streamInnerController = {};

  final List<BasePage> _outerPages = [];
  Map<String, InitPage> _initPages = {};

  Stream<List<MaterialPage>> get outerStream => _streamOuterController.stream;
  Stream<List<MaterialPage>>? getInnerStream(String routerName) =>
      _streamInnerController[routerName]?.stream;

  BasePage? _currentRouter;

  String get currentRouter => _currentRouter?.routerName ?? homePath;

  _updatePages(String routerName, {String? parentName}) {
    if (parentName == null) {
      _outerPages.removeWhere((element) => element.routerName == routerName);
      return;
    }
    final page = _outerPages.getByName(parentName);
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }

    page.innerPages.removeWhere((element) => element.routerName == routerName);
  }

  /// Set pages will display in App
  void setInitPages(Map<String, InitPage> initPages) {
    _initPages = initPages;
  }

  /// set Homepage
  void setHomeRouter(String routerName) {
    final page = _initPages[routerName];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }
    homePath = routerName;
    homeRouter = page.toBasePage(routerName);
    showHomePage();
  }

  /// set HomePage of nested pages if has any
  void setInitInnerRouter(String routerName) {
    final page = _initPages[routerName];
    if (page == null || page.parentName == null) {
      throw Exception(['Can not find this page or this page has no parent']);
    }
    final parentRouter = _outerPages.getByName(page.parentName!);
    if (parentRouter == null || parentRouter.innerPages.isNotEmpty) return;
    final router = page.toBasePage(routerName);
    parentRouter.innerPages.add(router);
    _currentRouter = router;
    _streamInnerController[parentRouter.routerName] =
        BehaviorSubject<List<MaterialPage>>.seeded(
            parentRouter.innerPages.getMaterialPage());
  }

  /// set UnknownPage on Web
  void setUnknownPage(String name) {
    final page = _initPages[name];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }

    unknownRouter = page.toBasePage(name);
  }

  /// show UnknownPage
  void showUnknownPage() {
    _outerPages
      ..clear()
      ..add(unknownRouter);
    _currentRouter = unknownRouter;
    _streamOuterController.add(_outerPages.getMaterialPage());
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  /// show HomePage
  void showHomePage() {
    _outerPages
      ..clear()
      ..add(homeRouter);
    _currentRouter = homeRouter;
    _streamOuterController.add(_outerPages.getMaterialPage());
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  /// push a page
  void pushNamed(String routerName) {
    final page = _initPages[routerName];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }
    if (_outerPages.isNotEmpty) {
      _updatePages(routerName, parentName: page.parentName);
    }
    final router = page.toBasePage(routerName);
    _currentRouter = router;
    if (page.parentName == null) {
      _outerPages.add(router);
      _streamOuterController.add(_outerPages.getMaterialPage());
      return;
    }
    final parentRouter = _outerPages.getByName(page.parentName!);
    parentRouter?.innerPages.add(router);
    _streamInnerController[page.parentName]
        ?.add(parentRouter?.innerPages.getMaterialPage() ?? []);
  }

  /// remove last page
  void pop() {
    final parentName = _currentRouter?.parentName;
    if (parentName == null && _outerPages.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerPages.last;
    if (parentName != null && lastParent.pop()) {
      _currentRouter = lastParent.innerPages.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerPages.getMaterialPage());
      return;
    }
    _outerPages.removeLast();
    _currentRouter = _outerPages.last;
    _streamOuterController.add(_outerPages.getMaterialPage());
  }

  /// remove several pages until page with routerName
  void popUntil(String routerName) {
    final parentName = _initPages[routerName]?.parentName;
    if (parentName == null && _outerPages.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerPages.last;
    if (parentName != null &&
        _outerPages.getByName(parentName)?.popUntil(routerName) == true) {
      _currentRouter = lastParent.innerPages.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerPages.getMaterialPage());
      return;
    }
    _outerPages.removeLast();
    _currentRouter = _outerPages.last;
    _streamOuterController.add(_outerPages.getMaterialPage());
  }

  /// remove last page and replace this with new one
  void popAndReplaceNamed(String routerName) {
    final newPage = _initPages[routerName];
    if (newPage == null) {
      throw Exception(['Can not find a page with this name']);
    }
    final parentName = newPage.parentName;
    if (parentName == null && _outerPages.isEmpty) {
      throw Exception(['Can not pop: no backward router']);
    }

    if (parentName != null) {
      final lastParent = _outerPages.last;
      lastParent.popAndAddInner(newPage.toBasePage(routerName));
      _currentRouter = lastParent.innerPages.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerPages.getMaterialPage());
      return;
    }
    final oldLast = _outerPages.removeLast();
    _outerPages.add(newPage.toBasePage(routerName));
    _currentRouter = _outerPages.last;
    _streamOuterController.add(_outerPages.getMaterialPage());
    _streamInnerController[oldLast.routerName]?.close();
  }

  /// remove all and add a page
  void popAllAndPushNamed(String routerName) {
    final page = _initPages[routerName];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }
    final newPage = page.toBasePage(routerName);

    if (page.parentName == null) {
      _outerPages
        ..clear()
        ..add(newPage);
      _currentRouter = newPage;
      _streamOuterController.add(_outerPages.getMaterialPage());
      _streamInnerController.forEach((key, value) {
        value.close();
      });
      return;
    }
    final parentPage = _outerPages.getByName(page.parentName!);
    if (parentPage == null) {
      throw Exception(['Can not find parent for this page']);
    }

    parentPage.popAllAndPushInner(newPage);
    _currentRouter = parentPage.innerPages.last;
    _streamInnerController[page.parentName]
        ?.add(parentPage.innerPages.getMaterialPage());
  }

  /// check a page is active or not
  bool checkActiveRouter(String routerName) {
    if (routerName == homePath) return true;
    final page = _initPages[routerName];
    if (page?.parentName == null) {
      return _outerPages.firstWhereOrNull(
              (element) => element.routerName == routerName) !=
          null;
    }
    return _outerPages
            .firstWhereOrNull(
                (element) => element.routerName == page?.parentName)
            ?.innerPages
            .firstWhereOrNull((element) => element.routerName == routerName) !=
        null;
  }

  /// only for web with path on browser
  void setOuterPagesForWeb(List<String> listRouter) {
    listRouter.removeWhere((element) => element == '');
    _outerPages.clear();
    for (var routerName in listRouter) {
      if (!routerName.startsWith('/')) {
        routerName = '/$routerName';
      }
      final page = _initPages[routerName];
      if (page == null) {
        _outerPages
          ..clear()
          ..add(unknownRouter);
        return;
      }

      _outerPages.add(page.toBasePage(routerName));
    }
    _streamOuterController.add(_outerPages.getMaterialPage());
  }

  /// only for web with path on browser
  void setInnerPagesForWeb(
      {required parentName, List<String> listRouter = const []}) {
    final parentPage = _outerPages.getByName(parentName);
    if (parentPage == null) return;
    for (var routerName in listRouter) {
      final page = _initPages[routerName];
      if (page == null) {
        return;
      }

      parentPage.addInner(page.toBasePage(routerName));
    }
    _streamInnerController[parentName]
        ?.add(parentPage.innerPages.getMaterialPage());
  }

  getPath() {
    String path = '';
    for (var element in _outerPages) {
      path += element.routerName;
    }
    return path;
  }
}
