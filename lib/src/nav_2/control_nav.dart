import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/appnav_interfaces.dart';
import 'package:flutter/material.dart';

import 'custom_router.dart';

String homePath = '/';
const unknownPath = '/unknown';
const lostConnectedPath = '/lostConnected';

final class AppNav implements AppNavInterfaces {
  // ✅ Only outer router management
  final Map<String, BaseRouter> _outerRouterMap = {};
  final Map<String, InitRouter> _initRouters = {};
  final List<String> _outerRouterOrder = [];
  
  // ✅ Simplified cache: String -> MaterialPage for outer routers only
  final Map<String, MaterialPage> _outerPageCache = {};
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

  // ✅ Only outer stream controller
  final _streamOuterController = InnerObserver<List<MaterialPage>>(initValue: []);

  InnerObserver<List<MaterialPage>> get outerStream => _streamOuterController;
  
  // ✅ Get inner stream directly from the router
  InnerObserver<List<MaterialPage>>? getInnerStream(String routerName) {
    final router = _outerRouterMap[routerName];
    return router?.innerStream;
  }

  // ✅ Get current router from last outer router
  String get currentRouter {
    if (_outerRouterOrder.isEmpty) return homePath;
    final lastRouterName = _outerRouterOrder.last;
    return _outerRouterMap[lastRouterName]?.routerName ?? homePath;
  }

  // ✅ Get parent router from last outer router
  String? get parentRouter {
    if (_outerRouterOrder.isEmpty) return null;
    final lastRouterName = _outerRouterOrder.last;
    return _outerRouterMap[lastRouterName]?.parentName;
  }

  @override
  dynamic get navigationArg {
    if (_outerRouterOrder.isEmpty) return null;
    final lastRouterName = _outerRouterOrder.last;
    return _outerRouterMap[lastRouterName]?.argumentNav;
  }

  @override
  dynamic get currentArguments {
    if (_outerRouterOrder.isEmpty) return null;
    final lastRouterName = _outerRouterOrder.last;
    return _outerRouterMap[lastRouterName]?.arguments;
  }

    // ✅ Utility methods
  bool checkActiveRouter(String routerName, {String? parentName}) {
    if (routerName == '/') return true;
    
    if (parentName == null) {
      return _outerRouterMap.containsKey(routerName);
    }
    
    final parentRouter = _outerRouterMap[parentName];
    return parentRouter?.hasInnerRouter(routerName) ?? false;
  }

  // ✅ Simplified duplicate removal - router handles inner logic
  void _removeDuplicate(String routerName, {String? parentName}) {
    if (parentName == null) {
      if (_outerRouterMap.containsKey(routerName)) {
        _outerRouterMap.remove(routerName);
        _outerRouterOrder.remove(routerName);
        _invalidateOuterCache();
      }
      return;
    }
    
    final router = _outerRouterMap[parentName];
    if (router == null) {
      throw Exception('Can not find a router with this name');
    }
    
    router.removeInnerRouter(routerName); // ✅ Router handles its own inner logic
  }

  InitRouter _validateRouterName(String routerName) {
    final router = _initRouters[routerName];
    if (router == null) {
      throw Exception('Router not found: $routerName');
    }
    return router;
  }

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

  // ✅ Set initial inner router for a parent router
  void setInitInnerRouter(String routerName, String parentName) {
    final initRouter = _validateRouterName(routerName);
    final parentRouter = _validateParentRouter(parentName);
    
    final innerRouter = initRouter.toBaseRouter(
      routerName,
      parentName: parentName,
    );
    
    // ✅ Add as initial inner router (don't remove duplicates for init)
    parentRouter.addInner(innerRouter);
    
   
  }

  void setInitRouters(Map<String, InitRouter> initRouters) {
    _initRouters.addAll(initRouters);
  }

  // ✅ Simplified outer cache management
  void _invalidateOuterCache() {
    _outerCacheInvalid = true;
    _outerPageCache.clear();
  }

  // ✅ Remove specific router from cache
  void _removeFromOuterCache(String routerName) {
    _outerPageCache.remove(routerName);
  }

  // ✅ Simplified outer page generation with individual caching
  List<MaterialPage> _getOuterMaterialPages() {
    if (_outerCacheInvalid) {
      // Full rebuild - clear and regenerate all
      _outerPageCache.clear();
      for (final routerName in _outerRouterOrder) {
        final router = _outerRouterMap[routerName];
        if (router != null) {
          _outerPageCache[routerName] = router.getRouter();
        }
      }
      _outerCacheInvalid = false;
    } else {
      // Partial update - only add missing pages
      for (final routerName in _outerRouterOrder) {
        if (!_outerPageCache.containsKey(routerName)) {
          final router = _outerRouterMap[routerName];
          if (router != null) {
            _outerPageCache[routerName] = router.getRouter();
          }
        }
      }
    }
    
    // Return pages in correct order
    return _outerRouterOrder
        .where((name) => _outerPageCache.containsKey(name))
        .map((name) => _outerPageCache[name]!)
        .toList(growable: false);
  }

  void _updateOuter(BaseRouter router) {
    _streamOuterController.value = _getOuterMaterialPages();
  }

  // ✅ Simplified router stack update
  void _updateRouterStack(BaseRouter newRouter, {String? parentName}) {
    if (parentName == null) {
      _outerRouterMap[newRouter.routerName] = newRouter;
      _outerRouterOrder.add(newRouter.routerName);
      // ✅ Add only the new router to cache instead of invalidating all
      _outerPageCache[newRouter.routerName] = newRouter.getRouter();
      _updateOuter(newRouter);
    } else {
      final parentRouter = _validateParentRouter(parentName);
      parentRouter.addInner(newRouter);
      // ✅ No cache management needed for inner - router handles it
    }
  }

  // ✅ System navigation methods (splash, home, unknown, etc.)
  void goSplashScreen(String routerName) {
    final router = _validateRouterName(routerName);
    final splashRouter = router.toBaseRouter(routerName);
    
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _outerPageCache.clear();
    
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

  void showHomeRouter() {
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _outerPageCache.clear();
    
    _outerRouterMap[homePath] = homeRouter;
    _outerRouterOrder.add(homePath);
    _updateOuter(homeRouter);
  }

  void setUnknownRouter(String name) {
    final router = _validateRouterName(name);
    unknownRouter = router.toBaseRouter(unknownPath);
  }

  void showUnknownRouter() {
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _outerPageCache.clear();
    
    _outerRouterMap[unknownPath] = unknownRouter;
    _outerRouterOrder.add(unknownPath);
    _updateOuter(unknownRouter);
  }

  void setLostConnectedRouter(String name) {
    final router = _validateRouterName(name);
    lostConnectedRouter = router.toBaseRouter(lostConnectedPath);
  }

  void showLostConnectedRouter() {
    _removeDuplicate(lostConnectedPath);
    _outerRouterMap[lostConnectedPath] = lostConnectedRouter;
    _outerRouterOrder.add(lostConnectedPath);
    _outerPageCache[lostConnectedPath] = lostConnectedRouter.getRouter();
    _updateOuter(lostConnectedRouter);
  }

  // ✅ Core navigation interface methods
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
      final removedRouter = _outerRouterMap.remove(lastRouterName);
      removedRouter?.dispose();
      
      // ✅ Remove specific router from cache
      _removeFromOuterCache(lastRouterName);
      _updateRouterStack(newRouter);
    } else {
      final parentRouter = _validateParentRouter(parentName);
      parentRouter.popAndAddInner(newRouter);
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
      // Clear all outer routers
      for (final router in _outerRouterMap.values) {
        router.dispose();
      }
      _outerRouterMap.clear();
      _outerRouterOrder.clear();
      _outerPageCache.clear();
      
      _updateRouterStack(newRouter);
    } else {
      final parentRouter = _validateParentRouter(parentName);
      parentRouter.popAllAndPushInner(newRouter);
    }
  }

  @override
  void pop({String? parentName}) {
    if (parentName != null) {
      // ✅ Inner navigation - let router handle it
      final parentRouter = _validateParentRouter(parentName);
      if (parentRouter.pop()) {
        return;
      }
      throw Exception('Cannot pop: no inner router available in $parentName');
    }
    
    // ✅ Outer navigation
    _ensureStackNotEmpty();
    
    if (_outerRouterOrder.isNotEmpty) {
      final lastRouterName = _outerRouterOrder.last;
      final lastRouter = _outerRouterMap[lastRouterName];
      
      if (lastRouter == null) {
        debugPrint('Warning: Trying to pop non-existent router: $lastRouterName');
        return;
      }
      
      // Try to pop inner first
      if (lastRouter.pop()) {
        return;
      }
      
      // Pop outer router
      final removedName = _outerRouterOrder.removeLast();
      final removedRouter = _outerRouterMap.remove(removedName);
      
      removedRouter?.dispose();
      
      // ✅ Remove specific router from cache
      _removeFromOuterCache(removedName);
      
      if (_outerRouterOrder.isNotEmpty) {
        final newLastName = _outerRouterOrder.last;
        final newLastRouter = _outerRouterMap[newLastName];
        if (newLastRouter != null) {
          _updateOuter(newLastRouter);
        }
      }
    }
  }

  @override
  void popUntil(String routerName, {String? parentName}) {
    _validateRouterName(routerName);
    
    if (parentName != null) {
      // ✅ Inner navigation - let router handle it
      final parentRouter = _validateParentRouter(parentName);
      if (parentRouter.popUntil(routerName)) {
        return;
      }
      throw Exception('Cannot popUntil: router $routerName not found in $parentName');
    }
    
    // ✅ Outer navigation
    _ensureStackNotEmpty();
    
    final targetIndex = _outerRouterOrder.indexOf(routerName);
    if (targetIndex >= 0) {
      final routersToRemove = _outerRouterOrder.sublist(targetIndex + 1);
      for (final name in routersToRemove) {
        final router = _outerRouterMap.remove(name);
        router?.dispose();
        // ✅ Remove specific routers from cache
        _removeFromOuterCache(name);
      }
      
      _outerRouterOrder.length = targetIndex + 1;
      
      if (_outerRouterOrder.isNotEmpty) {
        final lastRouterName = _outerRouterOrder.last;
        final lastRouter = _outerRouterMap[lastRouterName];
        if (lastRouter != null) {
          _updateOuter(lastRouter);
        }
      }
    }
  }

  // ✅ Web navigation methods updated
  void setOuterRoutersForWeb(List<String> listRouter) {
    listRouter.removeWhere((element) => element.isEmpty);
    
    // Dispose existing routers
    for (final router in _outerRouterMap.values) {
      router.dispose();
    }
    _outerRouterMap.clear();
    _outerRouterOrder.clear();
    _outerPageCache.clear();
    
    for (var routerName in listRouter) {
      if (!routerName.startsWith('/')) {
        routerName = '/$routerName';
      }
      
      final router = _initRouters[routerName];
      if (router == null) {
        _outerRouterMap.clear();
        _outerRouterOrder.clear();
        _outerPageCache.clear();
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
      final lastRouter = _outerRouterMap[lastRouterName];
      if (lastRouter != null) {
        _updateOuter(lastRouter);
      }
    }
  }

  void setInnerRoutersForWeb({
    required String parentName,
    List<String> listRouter = const [],
    dynamic arguments,
  }) {
    final parentRouter = _outerRouterMap[parentName];
    if (parentRouter == null) return;
    
    // ✅ Router handles its own inner navigation
    for (var routerName in listRouter) {
      final router = _initRouters[routerName];
      if (router == null) return;
      
      parentRouter.addInner(router.toBaseRouter(
        routerName,
        arguments: arguments,
        parentName: parentName,
      ));
    }
  }

  String getPath() {
    return _outerRouterOrder.join('');
  }
}