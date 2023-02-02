import 'package:base/src/interfaces/appnav_interfaces.dart';
import 'package:base/src/interfaces/dialognav_interfaces.dart';
import 'package:base/src/nav_dialog/navigator_dialog.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import 'custom_page.dart';

String homePath = '/';
const unknownPath = '/unknown';
const lostConnectedPath = '/lostConnected';

/// This is the place you can controll your app flow with Navigation 2.0
/// [AppNav] have to be used with [HomeRouterDelegate],
/// [HomeRouteInformationParser] and [InnerDelegateRouter]
/// for controlling your entire app.
///
class AppNav implements AppNavInterfaces, DialogNavigatorInterfaces {
  final _dialogNav = DialogNavigator();

  /// UnknownRouter can be update during app, so you can show different page
  /// for each unknownRouter.
  var unknownRouter =
      BasePage(routerName: unknownPath, widget: () => Container());

  /// this is HomeRouter which will show when you open the app.
  late final BasePage homeRouter;
  late final BasePage lostConnectedRouter;

  /// The Navigator stack is updated with these stream
  /// [_streamOuterController] for main flow and [_streamInnerController] for nested stack
  final _streamOuterController = BehaviorSubject<List<MaterialPage>>();
  final Map<String, BehaviorSubject<List<MaterialPage>>>
      _streamInnerController = {};

  /// This is pages will be shown in Navigator.
  final List<BasePage> _outerPages = [];
  Map<String, InitPage> _initPages = {};

  Stream<List<MaterialPage>> get outerStream => _streamOuterController.stream;
  Stream<List<MaterialPage>>? getInnerStream(String routerName) =>
      _streamInnerController[routerName]?.stream;

  /// currentRouter, this can be in main flow or nested flow
  BasePage? _currentRouter;

  String get currentRouter => _currentRouter?.routerName ?? homePath;

  /// argument when navigation.
  dynamic get _arguments => _currentRouter?.argument;

  _removeDuplicate(String routerName, {String? parentName}) {
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

  _updateOuter() {
    _streamOuterController
        .add([..._outerPages.getMaterialPage(), ..._dialogNav.listDialog]);
  }

  /// set Homepage
  void setHomeRouter(String routerName) {
    final page = _initPages[routerName];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }
    homePath = routerName;
    homeRouter = page.toBasePage(homePath);
    showHomePage();
  }

  /// set HomePage of nested pages if has any
  void setInitInnerRouter(String routerName) {
    final page = _initPages[routerName];
    if (page == null || page.parentName == null) {
      throw Exception(['Can not find this page or this page has no parent']);
    }
    final parentRouter = _outerPages.getByName(page.parentName!);
    if (parentRouter == null) {
      throw Exception(['Parent is not in outer routing']);
    }

    if (parentRouter.innerPages.isNotEmpty) return;

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

    unknownRouter = page.toBasePage(unknownPath);
  }

  /// show UnknownPage
  void showUnknownPage() {
    _outerPages
      ..clear()
      ..add(unknownRouter);
    _currentRouter = unknownRouter;
    _updateOuter();
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
    _updateOuter();
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  void setLostConnectedPage(String name) {
    final page = _initPages[name];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }
    lostConnectedRouter = page.toBasePage(lostConnectedPath);
  }

  void showLostConnectedPage() {
    _outerPages.add(lostConnectedRouter);
    _currentRouter = lostConnectedRouter;
    _updateOuter();
  }

  @override
  /// push a page
  void pushNamed(String routerName) {
    final initPage = _initPages[routerName];
    // check page exist
    if (initPage == null) {
      throw Exception(['Can not find a page with this name']);
    }
    _removeDuplicate(routerName, parentName: initPage.parentName);
    final router = initPage.toBasePage(routerName);
    _currentRouter = router;
    // add new page to outer routing if it has no parent.
    if (initPage.parentName == null) {
      _outerPages.add(router);
      _updateOuter();
      // final currentRouting = _streamOuterController.value;
      // currentRouting.add(router.getPage());
      // _streamOuterController.add(currentRouting);
      return;
    }
    // add new page to inner routing if it has parent.
    final parentRouter = _outerPages.getByName(initPage.parentName!);
    parentRouter?.innerPages.add(router);
    _streamInnerController[initPage.parentName]
        ?.add(parentRouter?.innerPages.getMaterialPage() ?? []);
  }

  /// remove last page
  @override
  void pop() {
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 page, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is inner routing but has only one inner page, solution: pop parent page
    final parentName = _currentRouter?.parentName;
    // case 1:
    if (parentName == null && _outerPages.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerPages.last;
    // case 2:
    if (parentName != null && lastParent.pop()) {
      _currentRouter = lastParent.innerPages.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerPages.getMaterialPage());
      return;
    }
    // case 3:
    final oldPage = _outerPages.removeLast();
    _currentRouter = _outerPages.last;
    _updateOuter();
    _streamInnerController[oldPage.routerName]?.close();
  }

  /// remove several pages until page with routerName
  @override
  void popUntil(String routerName) {
    // there are 3 cases:
    // 1. This is outer routing and there are only 1 page, solution: can not pop
    // 2. This is inner routing and can pop.
    // 3. This is outer routing.
    final parentName = _initPages[routerName]?.parentName;
    // case 1:
    if (parentName == null && _outerPages.length <= 1) {
      throw Exception(['Can not pop: no backward router']);
    }
    final lastParent = _outerPages.last;
    // case 2:
    if (parentName != null &&
        _outerPages.getByName(parentName)?.popUntil(routerName) == true) {
      _currentRouter = lastParent.innerPages.last;
      _streamInnerController[parentName]
          ?.add(lastParent.innerPages.getMaterialPage());
      return;
    }
    // case 3:
    _outerPages.length =
        _outerPages.indexWhere((element) => element.routerName == routerName) +
            1;
    _currentRouter = _outerPages.last;
    _updateOuter();
  }

  /// remove last page and replace this with new one
  @override
  void popAndReplaceNamed(String routerName) {
    final newPage = _initPages[routerName];
    // check if new page exist
    if (newPage == null) {
      throw Exception(['Can not find a page with this name']);
    }
    final parentName = newPage.parentName;

    if (parentName == null && _outerPages.isEmpty) {
      throw Exception(['Can not pop: no backward router']);
    }

    if (parentName != null) {
      final lastParent = _outerPages.last;
      if (lastParent.routerName != parentName) {
        throw Exception(['Last parent does not have this child']);
      }
      final childPage = newPage.toBasePage(routerName);
      lastParent.popAndAddInner(childPage);
      _currentRouter = childPage;
      _streamInnerController[parentName]
          ?.add(lastParent.innerPages.getMaterialPage());
      return;
    }
    final oldLast = _outerPages.removeLast();
    _outerPages.add(newPage.toBasePage(routerName));
    _currentRouter = _outerPages.last;
    _updateOuter();
    _streamInnerController[oldLast.routerName]?.close();
  }

  /// remove all and add a page
  @override
  void popAllAndPushNamed(String routerName) {
    final page = _initPages[routerName];
    if (page == null) {
      throw Exception(['Can not find a page with this name']);
    }
    if (page.parentName != null) {
      throw Exception(['Can not push an inner page: no parent found!']);
    }
    final newPage = page.toBasePage(routerName);

    _outerPages
      ..clear()
      ..add(newPage);
    _currentRouter = newPage;
    _updateOuter();
    _streamInnerController.forEach((key, value) {
      value.close();
    });
  }

  /// check a page is active or not
  bool checkActiveRouter(String routerName) {
    if (routerName == '/') return true;
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
    _updateOuter();
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

  @override
  removeAllDialog() {
    _dialogNav.removeAllDialog();
    _updateOuter();
  }

  @override
  removeDialog(DialogNameInterfaces name) {
    _dialogNav.removeDialog(name);
    _updateOuter();
  }

  @override
  showDialog({required Widget child, required DialogNameInterfaces name}) {
    _dialogNav.showDialog(child: child, name: name);
    _updateOuter();
  }

  @override
  getCurrentArgument() {
    return _arguments;
  }
}
