import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

const homePath = '/';
const unknownPath = '/unknown';

class NavNote {
  String routerName;
  int level;
  String? parentRouter;
  bool isInner;

  NavNote(
      {required this.routerName,
      this.level = 0,
      this.isInner = false,
      this.parentRouter});
}

class AppNav {
  final unknownRouter = NavNote(routerName: unknownPath);
  final homeRouter = NavNote(routerName: homePath);
  final List<NavNote> _navTree = [];
  final _streamOuterController = BehaviorSubject<List<MaterialPage>>();
  final _streamInnerController = BehaviorSubject<List<MaterialPage>>();

  final List<MaterialPage> _innerPages = [];
  final List<MaterialPage> _outerPages = [];
  Widget Function()? Function(String name) _initPages = (String name) {
    return null;
  };
  MaterialPage unknownPage =
      MaterialPage(child: Container(), name: unknownPath);

  MaterialPage homePage = MaterialPage(child: Container(), name: homePath, key: const ValueKey(homePath));

  Stream<List<MaterialPage<dynamic>>> get outerStream =>
      _streamOuterController.stream;
  Stream<List<MaterialPage<dynamic>>> get innerStream =>
      _streamInnerController.stream;

  bool _checkDuplicated(String routerName) {
    return _navTree
            .firstWhereOrNull((element) => element.routerName == routerName) !=
        null;
  }

  _updatePages(String routerName) {
    if (!_checkDuplicated(routerName)) {
      return;
    }
    _navTree.removeWhere((element) => element.routerName == routerName);
    _outerPages.removeWhere((element) => element.name == routerName);
    _innerPages.removeWhere((element) => element.name == routerName);
    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
  }

  /// Set pages will display in App
  void setInitPages(Widget Function()? Function(String name) initPages) {
    _initPages = initPages;
  }

  /// set Homepage
  void setHomeRouter(String routerName) {
    final page = _initPages(routerName);
    if (page == null || _outerPages.isNotEmpty) {
      return;
    }
    _navTree.add(NavNote(routerName: routerName));
    final router = MaterialPage(child: page(), name: routerName, key: ValueKey(routerName));
    homePage = router;
    _outerPages.add(router);
    _streamOuterController.add(_outerPages);
  }

  /// set HomePage of nested pages if has any
  void setInitInnerRouter(String routerName) {
    final page = _initPages(routerName);
    if (page == null || _innerPages.isNotEmpty) {
      return;
    }
    _navTree.add(NavNote(
        routerName: routerName,
        parentRouter: _outerPages.last.name,
        isInner: true));
    _innerPages.add(MaterialPage(child: page(), name: routerName, key: ValueKey(routerName)));
    _streamInnerController.add(_innerPages);
  }

  /// set UnknownPage on Web
  void setUnknownPage(MaterialPage page) {
    unknownPage = page;
  }

  /// show UnknownPage
  void showUnknownPage() {
    _navTree
      ..clear()
      ..add(unknownRouter);
    _innerPages.clear();
    _outerPages
      ..clear()
      ..add(unknownPage);
    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
  }

  /// show HomePage
  void showHomePage() {
    _navTree
      ..clear()
      ..add(homeRouter);
    _innerPages.clear();
    _outerPages
      ..clear()
      ..add(homePage);
    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
  }

  /// push a page
  void pushNamed(String routerName, {bool isInner = false}) {
    final page = _initPages(routerName);
    if (page == null) {
      return;
    }
    if (_navTree.isNotEmpty) {
      _updatePages(routerName);
      _navTree.add(NavNote(
          routerName: routerName,
          level: _navTree.last.level + 1,
          parentRouter: _navTree.last.routerName,
          isInner: isInner));
    } else {
      _navTree.add(NavNote(routerName: routerName));
    }
    final router = MaterialPage(child: page(), name: routerName, key: ValueKey(routerName));

    if (isInner) {
      _innerPages.add(router);
      _streamInnerController.add(_innerPages);
    } else {
      _outerPages.add(router);
      _streamOuterController.add(_outerPages);
    }
  }

  /// remove last page
  void pop() {
    if (_navTree.isEmpty) {
      return;
    }
    final note = _navTree.last;
    if (note.isInner && _innerPages.length > 1) {
      _navTree.removeLast();
      _innerPages.removeLast();
      _streamInnerController.add(_innerPages);
    }
    if (!note.isInner && _outerPages.length > 1) {
      _navTree.removeLast();
      _outerPages.removeLast();
      _streamOuterController.add(_outerPages);
    }
  }

  /// remove several pages until page with routerName
  void popUntil(String routerName) {
    final index =
        _navTree.indexWhere((element) => element.routerName == routerName);
    if (index == -1) {
      return;
    }

    for (int i = index; i < _navTree.length; i++) {
      final note = _navTree[i];
      if (note.isInner) {
        _innerPages.removeWhere((element) => element.name == note.routerName);
      } else {
        _outerPages.removeWhere((element) => element.name == note.routerName);
      }
    }
    _navTree.length = index;

    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
  }

  /// remove last page and replace this with new one
  void popAndReplaceNamed(String routerName) {
    final page = _initPages(routerName);
    if (page == null) {
      return;
    }
    if (_navTree.isEmpty) {
      _navTree.add(NavNote(routerName: routerName));
    } else {
      final note = _navTree.removeLast();
      _updatePages(routerName);
      _navTree.add(NavNote(
          routerName: routerName,
          level: note.level,
          parentRouter: note.parentRouter,
          isInner: note.isInner));
    }
    final router = MaterialPage(child: page(), name: routerName, key: ValueKey(routerName));
    if (_navTree.last.isInner) {
      _innerPages.removeLast();
      _innerPages.add(router);
      _streamInnerController.add(_innerPages);
    } else {
      _outerPages.isNotEmpty ? _outerPages.removeLast() : null;
      _outerPages.add(router);
      _streamOuterController.add(_outerPages);
    }
  }

  /// remove all and add a page
  void popAllAndPushNamed(String routerName) {
    final page = _initPages(routerName);
    if (page == null) {
      return;
    }
    _navTree
      ..clear()
      ..add(NavNote(routerName: routerName));
    final router = MaterialPage(child: page(), name: routerName, key: ValueKey(routerName));

    _innerPages.clear();
    _outerPages
      ..clear()
      ..add(router);
    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
  }

  /// get the last page name
  String getCurrentRouter() {
    if (_navTree.isEmpty) {
      return homePath;
    }
    return _navTree.last.routerName;
  }

  /// check a page is active or not
  bool checkActiveRouter(String routerName) {
    return _navTree.firstWhereOrNull(
                (element) => element.routerName == routerName) !=
            null ||
        routerName == homePath;
  }

  /// only for web with path on browser
  void setOuterPagesForWeb(List<String> listRouter) {
    _outerPages.clear();
    for (var routerName in listRouter) {
      final page = _initPages(routerName);
      if (page == null) {
        return;
      }
      if (_navTree.isEmpty) {
        _navTree.add(NavNote(routerName: routerName));
      } else {
        _navTree.add(NavNote(
            routerName: routerName,
            level: _navTree.last.level + 1,
            parentRouter: _navTree.last.routerName));
      }
      final router = MaterialPage(child: page(), name: routerName, key: ValueKey(routerName));
      _outerPages.add(router);
      _streamOuterController.add(_outerPages);
    }
  }

  /// only for web with path on browser
  void setInnerPagesForWeb(List<String> listRouter) {
    _innerPages.clear();
    for (var routerName in listRouter) {
      final page = _initPages(routerName);
      if (page == null) {
        return;
      }
      _navTree.add(NavNote(
          routerName: routerName,
          level: _navTree.last.level + 1,
          parentRouter: _navTree.last.routerName,
          isInner: true));
      final router = MaterialPage(child: page(), name: routerName, key: ValueKey(routerName));
      _innerPages.add(router);
      _streamInnerController.add(_innerPages);
    }
  }
}
