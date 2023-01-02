// import 'package:flutter/material.dart';
// import 'package:collection/collection.dart';

// const homePath = '/';
// const unknownPath = '/unknown';

// class NavNote {
//   String routerName;
//   int level;
//   String? parentRouter;
//   bool isInner;

//   NavNote(
//       {required this.routerName,
//       this.level = 0,
//       this.isInner = false,
//       this.parentRouter});
// }

// class AppNav {
//   final unknownRouter = NavNote(routerName: unknownPath);
//   final homeRouter = NavNote(routerName: homePath);
//   final List<NavNote> _navTree = [];
//   final List<MaterialPage> _outerPages = [];
//   final List<MaterialPage> _innerPages = [];
//   final List<MaterialPage> _initPages = [];
//   MaterialPage unknownPage =
//       MaterialPage(child: Container(), name: unknownPath);

//   MaterialPage homePage = MaterialPage(child: Container(), name: homePath);
//   NavNote? lastRouter;

//   List<MaterialPage<dynamic>> get _outerPages => _outerPages;
//   List<MaterialPage<dynamic>> get _innerPages => _innerPages;

//   /// Set pages will display in App
//   void setInitPages(List<MaterialPage> initPages) {
//     _initPages.addAll(initPages);
//   }

//   /// set Homepage
//   void setHomeRouter(String routerName) {
//     final router =
//         _initPages.firstWhereOrNull((element) => element.name == routerName);
//     if (router == null) {
//       return;
//     }
//     homePage = router;
//     _navTree.add(NavNote(routerName: routerName));
//     _outerPages.add(router);
//     lastRouter = _navTree.last;
//   }

//   /// set HomePage of nested pages if has any
//   void setInitInnerRouter(String routerName) {
//     final router =
//         _initPages.firstWhereOrNull((element) => element.name == routerName);
//     if (router == null) {
//       return;
//     }
//     _navTree.add(NavNote(
//         routerName: routerName,
//         parentRouter: _outerPages.last.name,
//         isInner: true));
//     _innerPages.add(router);
//     lastRouter = _navTree.last;
//   }

//   /// set UnknownPage on Web
//   void setUnknownPage(MaterialPage page) {
//     unknownPage = page;
//   }

//   /// show UnknownPage
//   void showUnknownPage() {
//     _navTree
//       ..clear()
//       ..add(unknownRouter);
//     _innerPages.clear();
//     _outerPages
//       ..clear()
//       ..add(unknownPage);
//     lastRouter = _navTree.last;
//   }

//   /// show HomePage
//   void showHomePage() {
//     _navTree
//       ..clear()
//       ..add(homeRouter);
//     _innerPages.clear();
//     _outerPages
//       ..clear()
//       ..add(homePage);
//     lastRouter = _navTree.last;
//   }

//   /// push a page
//   void pushNamed(String routerName, {bool isInner = false}) {
//     final router =
//         _initPages.firstWhereOrNull((element) => element.name == routerName);
//     if (router == null) {
//       return;
//     }
//     if (lastRouter != null) {
//       _navTree.add(NavNote(
//           routerName: routerName,
//           level: lastRouter!.level + 1,
//           parentRouter: lastRouter!.routerName,
//           isInner: isInner));
//     } else {
//       _navTree.add(NavNote(routerName: routerName));
//     }
//     if (isInner) {
//       _innerPages.add(router);
//     } else {
//       _outerPages.add(router);
//     }
//     lastRouter = _navTree.last;
//   }

//   /// remove last page
//   void pop() {
//     if (lastRouter == null) {
//       return;
//     }
//     _navTree.removeLast();
//     if (_innerPages.isNotEmpty) {
//       _innerPages.removeLast();
//     } else {
//       _outerPages.removeLast();
//     }
//     lastRouter = _navTree.isEmpty ? null : _navTree.last;
//   }

//   /// remove several pages until page with routerName
//   void popUntil(String routerName) {
//     final index =
//         _navTree.indexWhere((element) => element.routerName == routerName);
//     if (index == -1) {
//       return;
//     }
//     _navTree.length = index;

//     if (index < _outerPages.length) {
//       _innerPages.clear();
//       _outerPages.length = index;
//     } else {
//       _innerPages.length = index - _outerPages.length;
//     }
//     lastRouter = _navTree.isEmpty ? null : _navTree.last;
//   }

//   /// remove last page and replace this with new one
//   void popAndReplaceNamed(String routerName) {
//     final router =
//         _initPages.firstWhereOrNull((element) => element.name == routerName);
//     if (router == null) {
//       return;
//     }
//     if (lastRouter == null) {
//       _navTree.add(NavNote(routerName: routerName));
//       _outerPages.add(router);
//     } else {
//       _navTree.removeLast();

//       _navTree.add(NavNote(
//           routerName: routerName,
//           level: lastRouter!.level + 1,
//           parentRouter: lastRouter!.routerName));
//       if (_innerPages.isNotEmpty) {
//         _innerPages.removeLast();
//         _innerPages.add(router);
//       } else {
//         _outerPages.removeLast();
//         _outerPages.add(router);
//       }
//     }
//     lastRouter = _navTree.last;
//   }

//   /// remove all and add a page
//   void popAllAndPushNamed(String routerName) {
//     final router =
//         _initPages.firstWhereOrNull((element) => element.name == routerName);
//     if (router == null) {
//       return;
//     }
//     _navTree
//       ..clear()
//       ..add(NavNote(routerName: routerName));
//     _innerPages.clear();
//     _outerPages
//       ..clear()
//       ..add(router);
//     lastRouter = _navTree.last;
//   }

//   /// get the last page name
//   String getCurrentRouter() {
//     return lastRouter?.routerName ?? homePath;
//   }

//   /// check a page is active or not
//   bool checkActiveRouter(String routerName) {
//     return _navTree
//             .firstWhereOrNull((element) => element.routerName == routerName) !=
//         null;
//   }

//   /// only for web with path on browser
//   void set_OuterPagesForWeb(List<String> listRouter) {
//     _outerPages.clear();
//     for (var routerName in listRouter) {
//       final router =
//           _initPages.firstWhereOrNull((element) => element.name == routerName);
//       if (router != null) {
//         _outerPages.add(router);
//         if (lastRouter == null) {
//           _navTree.add(NavNote(routerName: routerName));
//         } else {
//           _navTree.add(NavNote(
//               routerName: routerName,
//               level: lastRouter!.level + 1,
//               parentRouter: lastRouter!.routerName));
//         }
//       }
//     }
//   }

//   /// only for web with path on browser
//   void set_InnerPagesForWeb(List<String> listRouter) {
//     _innerPages.clear();
//     for (var routerName in listRouter) {
//       final router =
//           _initPages.firstWhereOrNull((element) => element.name == routerName);
//       if (router != null) {
//         _innerPages.add(router);

//         _navTree.add(NavNote(
//             routerName: routerName,
//             level: lastRouter!.level + 1,
//             parentRouter: lastRouter!.routerName,
//             isInner: true));
//       }
//     }
//   }
// }

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
  final List<MaterialPage> _initPages = [];
  MaterialPage unknownPage =
      MaterialPage(child: Container(), name: unknownPath);

  MaterialPage homePage = MaterialPage(child: Container(), name: homePath);
  NavNote? lastRouter;

  Stream<List<MaterialPage<dynamic>>> get outerStream => _streamOuterController.stream;
  Stream<List<MaterialPage<dynamic>>> get innerStream => _streamInnerController.stream;

  /// Set pages will display in App
  void setInitPages(List<MaterialPage> initPages) {
    _initPages.addAll(initPages);
  }

  /// set Homepage
  void setHomeRouter(String routerName) {
    final router =
        _initPages.firstWhereOrNull((element) => element.name == routerName);
    if (router == null) {
      return;
    }
    homePage = router;
    _navTree.add(NavNote(routerName: routerName));
    _outerPages.add(router);
    _streamOuterController.add(_outerPages);
    lastRouter = _navTree.last;
  }

  /// set HomePage of nested pages if has any
  void setInitInnerRouter(String routerName) {
    final router =
        _initPages.firstWhereOrNull((element) => element.name == routerName);
    if (router == null) {
      return;
    }
    _navTree.add(NavNote(
        routerName: routerName,
        parentRouter: _outerPages.last.name,
        isInner: true));
    _innerPages.add(router);
    _streamInnerController.add(_innerPages);
    lastRouter = _navTree.last;
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
    lastRouter = _navTree.last;
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
    lastRouter = _navTree.last;
  }

  /// push a page
  void pushNamed(String routerName, {bool isInner = false}) {
    final router =
        _initPages.firstWhereOrNull((element) => element.name == routerName);
    if (router == null) {
      return;
    }
    if (lastRouter != null) {
      _navTree.add(NavNote(
          routerName: routerName,
          level: lastRouter!.level + 1,
          parentRouter: lastRouter!.routerName,
          isInner: isInner));
    } else {
      _navTree.add(NavNote(routerName: routerName));
    }
    if (isInner) {
      _innerPages.add(router);
      _streamInnerController.add(_innerPages);
    } else {
      _outerPages.add(router);
      _streamOuterController.add(_outerPages);
    }
    lastRouter = _navTree.last;
  }

  /// remove last page
  void pop() {
    if (lastRouter == null) {
      return;
    }
    _navTree.removeLast();
    if (_innerPages.isNotEmpty) {
      _innerPages.removeLast();
      _streamInnerController.add(_innerPages);
    } else {
      _outerPages.removeLast();
      _streamOuterController.add(_outerPages);
    }
    lastRouter = _navTree.isEmpty ? null : _navTree.last;
  }

  /// remove several pages until page with routerName
  void popUntil(String routerName) {
    final index =
        _navTree.indexWhere((element) => element.routerName == routerName);
    if (index == -1) {
      return;
    }
    _navTree.length = index;

    if (index < _outerPages.length) {
      _innerPages.clear();
      _outerPages.length = index;
    } else {
      _innerPages.length = index - _outerPages.length;
    }
    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
    lastRouter = _navTree.isEmpty ? null : _navTree.last;
  }

  /// remove last page and replace this with new one
  void popAndReplaceNamed(String routerName) {
    final router =
        _initPages.firstWhereOrNull((element) => element.name == routerName);
    if (router == null) {
      return;
    }
    if (lastRouter == null) {
      _navTree.add(NavNote(routerName: routerName));
      _outerPages.add(router);
      _streamOuterController.add(_outerPages);
    } else {
      _navTree.removeLast();
      _navTree.add(NavNote(
          routerName: routerName,
          level: lastRouter!.level + 1,
          parentRouter: lastRouter!.routerName));
      if (_innerPages.isNotEmpty) {
        _innerPages.removeLast();
        _innerPages.add(router);
        _streamInnerController.add(_innerPages);
      } else {
        _outerPages.removeLast();
        _outerPages.add(router);
        _streamOuterController.add(_outerPages);
      }
    }
    lastRouter = _navTree.last;
  }

  /// remove all and add a page
  void popAllAndPushNamed(String routerName) {
    final router =
        _initPages.firstWhereOrNull((element) => element.name == routerName);
    if (router == null) {
      return;
    }
    _navTree
      ..clear()
      ..add(NavNote(routerName: routerName));
    _innerPages.clear();
    _outerPages
      ..clear()
      ..add(router);
    _streamOuterController.add(_outerPages);
    _streamInnerController.add(_innerPages);
    lastRouter = _navTree.last;
  }

  /// get the last page name
  String getCurrentRouter() {
    return lastRouter?.routerName ?? homePath;
  }

  /// check a page is active or not
  bool checkActiveRouter(String routerName) {
    return _navTree
            .firstWhereOrNull((element) => element.routerName == routerName) !=
        null;
  }

  /// only for web with path on browser
  void setOuterPagesForWeb(List<String> listRouter) {
    _outerPages.clear();
    for (var routerName in listRouter) {
      final router =
          _initPages.firstWhereOrNull((element) => element.name == routerName);
      if (router != null) {
        _outerPages.add(router);
        _streamOuterController.add(_outerPages);

        if (lastRouter == null) {
          _navTree.add(NavNote(routerName: routerName));
        } else {
          _navTree.add(NavNote(
              routerName: routerName,
              level: lastRouter!.level + 1,
              parentRouter: lastRouter!.routerName));
        }
      }
    }
  }

  /// only for web with path on browser
  void setInnerPagesForWeb(List<String> listRouter) {
    _innerPages.clear();
    for (var routerName in listRouter) {
      final router =
          _initPages.firstWhereOrNull((element) => element.name == routerName);
      if (router != null) {
        _innerPages.add(router);
        _streamInnerController.add(_innerPages);

        _navTree.add(NavNote(
            routerName: routerName,
            level: lastRouter!.level + 1,
            parentRouter: lastRouter!.routerName,
            isInner: true));
      }
    }
  }
}
