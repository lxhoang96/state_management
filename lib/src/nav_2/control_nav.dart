import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/appnav_interfaces.dart';
import 'package:flutter/material.dart';

import 'custom_router.dart';

String homePath = '/';
const unknownPath = '/unknown';
const lostConnectedPath = '/lostConnected';

final class AppNav implements AppNavInterfaces {
  // ✅ Cache routers by name for O(1) lookup
  final Map<String, BaseRouter> _outerRouterMap = {};
  final Map<String, InitRouter> _initRouters = {};
  
  // ✅ Keep ordered list for navigation stack
  final List<String> _outerRouterOrder = [];
  
  // ✅ Cache for MaterialPages to avoid recreation
  final Map<String, List<MaterialPage>> _materialPageCache = {};
  bool _outerCacheInvalid = true;
  
  BaseRouter unknownRouter = BaseRouter(
    routerName: unknownPath, 
    widget: () => Container()
  );
  
  BaseRouter homeRouter = BaseRouter(
    routerName: homePath, 
    widget: () => const SizedBox()
  );
  
  late final BaseRouter lostConnectedRouter;

  final _streamOuterController = InnerObserver<List<MaterialPage>>(initValue: []);
  final Map<String, InnerObserver<List<MaterialPage>>> _streamInnerController = {};

  BaseRouter? _currentRouter;

  InnerObserver<List<MaterialPage>> get outerStream => _streamOuterController;
  
  InnerObserver<List<MaterialPage>>? getInnerStream(String routerName) =>
      _streamInnerController[routerName];

  String get currentRouter => _currentRouter?.routerName ?? homePath;
  String? get parentRouter => _currentRouter?.parentName;

  @override
  dynamic get navigationArg => _currentRouter?.argumentNav;

  @override
  dynamic get currentArguments => _currentRouter?.arguments;

  // ✅ O(1) duplicate removal using Map
  void _removeDuplicate(String routerName, {String? parentName}) {
    if (parentName == null) {
      if (_outerRouterMap.containsKey(routerName)) {
        _outerRouterMap.remove(routerName);
        _outerRouterOrder.remove(routerName);
        _outerCacheInvalid = true;
      }
      return;
    }
    
    final router = _outerRouterMap[parentName];
    if (router == null) {
      throw Exception('Can not find a router with this name');
    }
    
    if (router.removeInnerRouter(routerName)) {
      _invalidateInnerCache(parentName);
    }
  }

  // ✅ O(1) router validation
  InitRouter _validateRouterName(String routerName) {
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception('Router not found: $routerName');
    }
    return router;
  }

  // ✅ O(1) parent validation
  BaseRouter _validateParentRouter(String parentName) {
    final parentRouter = _outerRouterMap[parentName];
    if (parentRouter == null) {
      throw Exception('Parent router not found: $parentName');
    }
    return parentRouter;
  }

  void _ensureStackNotEmpty({String? parentName}) {
    if (parentName == null && _outerRouterOrder.length <= 1) {
      throw Exception('Cannot pop: no backward router available.');
    }
  }

  // ✅ O(1) circular reference check
  void _preventCircularReference(String routerName, {String? parentName}) {
    if (parentName == null) {
      if (_outerRouterMap.containsKey(routerName)) {
        throw Exception('Circular reference detected for router: $routerName');
      }
    } else {
      final parentRouter = _validateParentRouter(parentName);
      if (parentRouter.hasInnerRouter(routerName)) {
        throw Exception('Circular reference detected for router: $routerName in parent: $parentName');
      }
    }
  }

  void setInitRouters(Map<String, InitRouter> initRouters) {
    _initRouters.addAll(initRouters);
  }

  // ✅ Optimized cache management
  void _invalidateOuterCache() {
    _outerCacheInvalid = true;
    _materialPageCache.remove('_outer');
  }

  void _invalidateInnerCache(String parentName) {
    // remove if no inner routers exist
    _materialPageCache.remove(parentName);
  }

//   void _invalidateInnerCache(String parentName) {
//   // ✅ Check if parent router still has inner routers
//   final parentRouter = _outerRouterMap[parentName];
//   if (parentRouter != null && !parentRouter.hasInnerRouters) {
//     // ✅ Parent has no more inner routers, remove it completely
//     _outerRouterOrder.remove(parentName);
//     _outerRouterMap.remove(parentName);
    
//     // ✅ Dispose and remove the inner stream controller
//     final oldInner = _streamInnerController.remove(parentName);
//     oldInner?.dispose();
    
//     // ✅ Update current router to the new last router
//     if (_outerRouterOrder.isNotEmpty) {
//       final newLastName = _outerRouterOrder.last;
//       _currentRouter = _outerRouterMap[newLastName]!;
//       _invalidateOuterCache();
//       _updateOuter(_currentRouter!);
//     }
//   }
  
//   // ✅ Always remove the cache regardless
//   _materialPageCache.remove(parentName);
// }

  // ✅ Cached MaterialPage generation
  List<MaterialPage> _getOuterMaterialPages() {
    if (_outerCacheInvalid || !_materialPageCache.containsKey('_outer')) {
      final pages = _outerRouterOrder
          .map((name) => _outerRouterMap[name]!)
          .map((router) => router.getRouter())
          .toList(growable: false);
      
      _materialPageCache['_outer'] = pages;
      _outerCacheInvalid = false;
    }
    
    return _materialPageCache['_outer']!;
  }

  List<MaterialPage> _getInnerMaterialPages(String parentName) {
    if (!_materialPageCache.containsKey(parentName)) {
      final parentRouter = _outerRouterMap[parentName];
      if (parentRouter != null) {
        final pages = parentRouter.innerRouters
            .map((router) => router.getRouter())
            .toList(growable: false);
        _materialPageCache[parentName] = pages;
      }
    }
    
    return _materialPageCache[parentName] ?? [];
  }

  void _updateOuter(BaseRouter router) {
    _currentRouter = router;
    _streamOuterController.value = _getOuterMaterialPages();
  }

  void _updateInner(String parentName) {
    final stream = _streamInnerController[parentName];
    if (stream != null) {
      stream.value = _getInnerMaterialPages(parentName);
    }
  }

  // ✅ Optimized methods with caching
  void goSplashScreen(String routerName) {
    final router = _validateRouterName(routerName);
    final splashRouter = router.toBaseRouter(routerName);
    
    // Clear all routers
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _materialPageCache.clear();
    
    // Dispose inner streams
    for (final stream in _streamInnerController.values) {
      stream.dispose();
    }
    _streamInnerController.clear();
    
    // Add splash router
    _outerRouterMap[routerName] = splashRouter;
    _outerRouterOrder.add(routerName);
    _updateOuter(splashRouter);
  }

  void setHomeRouter(String routerName) {
    final router = _validateRouterName(routerName);
    homePath = routerName;
    homeRouter = router.toBaseRouter(homePath);
    showHomeRouter();
  }

  void setInitInnerRouter(String routerName, String parentName, {dynamic arguments}) {
    final newPage = _validateRouterName(routerName);
    final parentRouter = _validateParentRouter(parentName);

    if (parentRouter.hasInnerRouters) return;

    final router = newPage.toBaseRouter(
      routerName,
      arguments: arguments,
      parentName: parentName,
    );
    
    parentRouter.addInner(router);
    _currentRouter = router;
    
    _streamInnerController[parentRouter.routerName] = InnerObserver<List<MaterialPage>>(
      initValue: _getInnerMaterialPages(parentRouter.routerName),
    );
  }

  void setUnknownRouter(String name) {
    final router = _validateRouterName(name);
    unknownRouter = router.toBaseRouter(unknownPath);
  }

  void showUnknownRouter() {
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _materialPageCache.clear();
    
    for (final stream in _streamInnerController.values) {
      stream.dispose();
    }
    _streamInnerController.clear();
    
    _outerRouterMap[unknownPath] = unknownRouter;
    _outerRouterOrder.add(unknownPath);
    _updateOuter(unknownRouter);
  }

  void showHomeRouter() {
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _materialPageCache.clear();
    
    for (final stream in _streamInnerController.values) {
      stream.dispose();
    }
    _streamInnerController.clear();
    
    _outerRouterMap[homePath] = homeRouter;
    _outerRouterOrder.add(homePath);
    _updateOuter(homeRouter);
  }

  void setLostConnectedRouter(String name) {
    final router = _validateRouterName(name);
    lostConnectedRouter = router.toBaseRouter(lostConnectedPath);
  }

  void showLostConnectedRouter() {
    _removeDuplicate(lostConnectedPath);
    _outerRouterMap[lostConnectedPath] = lostConnectedRouter;
    _outerRouterOrder.add(lostConnectedPath);
    _invalidateOuterCache();
    _updateOuter(lostConnectedRouter);
  }

  void _updateRouterStack(BaseRouter newRouter, {String? parentName}) {
    if (parentName == null) {
      _outerRouterMap[newRouter.routerName] = newRouter;
      _outerRouterOrder.add(newRouter.routerName);
      _invalidateOuterCache();
      _updateOuter(newRouter);
    } else {
      final parentRouter = _validateParentRouter(parentName);
      parentRouter.addInner(newRouter);
      _invalidateInnerCache(parentName);
      _updateInner(parentName);
    }
  }

  @override
  void pushNamed(String routerName, {String? parentName, dynamic arguments}) {
    final initRouter = _validateRouterName(routerName);
    _preventCircularReference(routerName, parentName: parentName);
    _removeDuplicate(routerName, parentName: parentName);
    
    final newRouter = initRouter.toBaseRouter(
      routerName,
      arguments: arguments,
      parentName: parentName,
    );
    
    _currentRouter = newRouter;
    _updateRouterStack(newRouter, parentName: parentName);
  }

  @override
  void popAndReplaceNamed(String routerName, {String? parentName, dynamic arguments}) {
    final initRouter = _validateRouterName(routerName);
    
    final newRouter = initRouter.toBaseRouter(
      routerName,
      arguments: arguments,
      parentName: parentName,
    );
    
    if (parentName == null) {
      if (_outerRouterOrder.isEmpty) {
        throw Exception('No routers to replace in outer stack');
      }
      
      final lastRouterName = _outerRouterOrder.removeLast();
      _outerRouterMap.remove(lastRouterName);
      _invalidateOuterCache();
      _updateRouterStack(newRouter);
    } else {
      final parentRouter = _validateParentRouter(parentName);
      parentRouter.popAndAddInner(newRouter);
      _currentRouter = newRouter;
      _invalidateInnerCache(parentName);
      _updateInner(parentName);
    }
  }

  @override
  void popAllAndPushNamed(String routerName, {String? parentName, dynamic arguments}) {
    final initRouter = _validateRouterName(routerName);
    _preventCircularReference(routerName, parentName: parentName);
    
    final newRouter = initRouter.toBaseRouter(
      routerName,
      arguments: arguments,
      parentName: parentName,
    );
    
    if (parentName == null) {
      _outerRouterMap.clear();
      _outerRouterOrder.clear();
      _materialPageCache.clear();
      
      for (final stream in _streamInnerController.values) {
        stream.dispose();
      }
      _streamInnerController.clear();
      
      _updateRouterStack(newRouter);
    } else {
      final parentRouter = _validateParentRouter(parentName);
      parentRouter.popAllAndPushInner(newRouter);
      _invalidateInnerCache(parentName);
      _updateInner(parentName);
    }
  }

  @override
  void pop() {
    _ensureStackNotEmpty();
    
    final parentName = _currentRouter?.parentName;
    
    if (_outerRouterOrder.isNotEmpty) {
      final lastRouterName = _outerRouterOrder.last;
      final lastParent = _outerRouterMap[lastRouterName]!;
      
      if (parentName != null && lastParent.pop()) {
        _currentRouter = lastParent.innerRouters.last;
        _invalidateInnerCache(parentName);
        _updateInner(parentName);
        return;
      }
      
      final removedName = _outerRouterOrder.removeLast();
      _outerRouterMap.remove(removedName);
      
      final oldInner = _streamInnerController.remove(removedName);
      oldInner?.dispose();
      
      _invalidateOuterCache();
      if (_outerRouterOrder.isNotEmpty) {
        final newLastName = _outerRouterOrder.last;
        _updateOuter(_outerRouterMap[newLastName]!);
      }
    }
  }

  @override
  void popUntil(String routerName, {String? parentName}) {
    _validateRouterName(routerName);
    _ensureStackNotEmpty(parentName: parentName);
    
    if (parentName != null) {
      final parentRouter = _validateParentRouter(parentName);
      if (parentRouter.popUntil(routerName)) {
        _currentRouter = parentRouter.innerRouters.last;
        _invalidateInnerCache(parentName);
        _updateInner(parentName);
        return;
      }
    }
    
    final targetIndex = _outerRouterOrder.indexOf(routerName);
    if (targetIndex >= 0) {
      // Remove routers after target
      final routersToRemove = _outerRouterOrder.sublist(targetIndex + 1);
      for (final name in routersToRemove) {
        _outerRouterMap.remove(name);
        _streamInnerController.remove(name)?.dispose();
      }
      
      _outerRouterOrder.length = targetIndex + 1;
      _invalidateOuterCache();
      
      if (_outerRouterOrder.isNotEmpty) {
        final lastRouterName = _outerRouterOrder.last;
        _updateOuter(_outerRouterMap[lastRouterName]!);
      }
    }
  }

  // ✅ O(1) router checking
  bool checkActiveRouter(String routerName, {String? parentName}) {
    if (routerName == '/') return true;
    
    if (parentName == null) {
      return _outerRouterMap.containsKey(routerName);
    }
    
    final parentRouter = _outerRouterMap[parentName];
    return parentRouter?.hasInnerRouter(routerName) ?? false;
  }

  void setOuterRoutersForWeb(List<String> listRouter) {
    listRouter.removeWhere((element) => element.isEmpty);
    
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _materialPageCache.clear();
    
    for (var routerName in listRouter) {
      if (!routerName.startsWith('/')) {
        routerName = '/$routerName';
      }
      
      final router = _initRouters[routerName];
      if (router == null) {
        _outerRouterMap.clear();
        _outerRouterOrder.clear();
        _outerRouterMap[unknownPath] = unknownRouter;
        _outerRouterOrder.add(unknownPath);
        return;
      }
      
      final newRouter = router.toBaseRouter(routerName, arguments: currentArguments);
      _outerRouterMap[routerName] = newRouter;
      _outerRouterOrder.add(routerName);
    }
    
    if (_outerRouterOrder.isNotEmpty) {
      final lastRouterName = _outerRouterOrder.last;
      _updateOuter(_outerRouterMap[lastRouterName]!);
    }
  }

  void setInnerRoutersForWeb({
    required String parentName,
    List<String> listRouter = const [],
    dynamic arguments,
  }) {
    final parentRouter = _outerRouterMap[parentName];
    if (parentRouter == null) return;
    
    for (var routerName in listRouter) {
      final router = _initRouters[routerName];
      if (router == null) return;
      
      parentRouter.addInner(router.toBaseRouter(
        routerName,
        arguments: arguments,
        parentName: parentName,
      ));
    }
    
    _invalidateInnerCache(parentName);
    _updateInner(parentName);
  }

  String getPath() {
    return _outerRouterOrder.join('');
  }
}