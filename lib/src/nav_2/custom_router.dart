import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// It is where your navigator flow starts.
/// Each [InitRouter] present a router later.
/// It contains a function returns Widget, [argumentNav] and [parentName] (optional)
final class InitRouter {
  final Widget Function() widget;
  final dynamic argumentNav;
  
  InitRouter({
    required this.widget,
    this.argumentNav,
  });

  BaseRouter toBaseRouter(String routerName,
      {String? parentName, dynamic arguments}) {
    return BaseRouter(
      routerName: routerName,
      widget: widget,
      parentName: parentName,
      argumentNav: argumentNav,
      arguments: arguments,
    );
  }
}

/// A BaseRouter extends InitRouter to return a Router with
/// String [routerName] and List of BaseRouter [innerRouters] (optional)
final class BaseRouter {
  final String routerName;
  final String? parentName;
  final dynamic arguments;
  final dynamic argumentNav;
  final Widget Function() _widget;
  
  // ✅ Cache the key to avoid recreation
  late final LocalKey _key = ValueKey(routerName);
  
  // ✅ Cache the page but allow invalidation
  MaterialPage? _cachedPage;
  bool _isPageInvalidated = false;
  
  // ✅ Use a more efficient data structure for inner routers
  final List<BaseRouter> _innerRouters = [];
  
  BaseRouter({
    required this.routerName,
    required Widget Function() widget,
    this.parentName,
    this.arguments,
    this.argumentNav,
  }) : _widget = widget;

  // ✅ Getter for inner routers (read-only access)
  List<BaseRouter> get innerRouters => List.unmodifiable(_innerRouters);
  
  // ✅ Check if router has inner routes
  bool get hasInnerRouters => _innerRouters.isNotEmpty;
  
  // ✅ Get inner router count efficiently
  int get innerRouterCount => _innerRouters.length;

  MaterialPage _createPage() {
    return MaterialPage(
      child: _widget(),
      name: routerName,
      key: _key,
      arguments: arguments,
    );
  }

  MaterialPage getRouter() {
    // ✅ Only recreate page if invalidated or not cached
    if (_cachedPage == null || _isPageInvalidated) {
      _cachedPage = _createPage();
      _isPageInvalidated = false;
    }
    return _cachedPage!;
  }
  
  // ✅ Invalidate cached page when needed
  void invalidatePage() {
    _isPageInvalidated = true;
  }
  
  // ✅ Dispose of cached resources
  void dispose() {
    _cachedPage = null;
    _innerRouters.clear();
  }
}

// ✅ Improved extension with better performance and validation
extension BaseRouterExtension on BaseRouter {
  /// Add inner router with validation
  bool addInner(BaseRouter innerRouter) {
    // Prevent duplicate router names
    if (_innerRouters.any((router) => router.routerName == innerRouter.routerName)) {
      return false;
    }
    _innerRouters.add(innerRouter);
    return true;
  }
  
  /// Pop last inner router
  bool pop() {
    if (_innerRouters.length <= 1) return false;
    final removed = _innerRouters.removeLast();
    removed.dispose(); // ✅ Clean up removed router
    return true;
  }

  /// Pop all and push new inner router
  void popAllAndPushInner(BaseRouter innerRouter) {
    // ✅ Dispose all existing routers
    for (final router in _innerRouters) {
      router.dispose();
    }
    _innerRouters.clear();
    _innerRouters.add(innerRouter);
  }

  /// Pop last and add new inner router
  void popAndAddInner(BaseRouter innerRouter) {
    if (_innerRouters.isNotEmpty) {
      final removed = _innerRouters.removeLast();
      removed.dispose(); // ✅ Clean up removed router
    }
    _innerRouters.add(innerRouter);
  }

  /// Pop until specific inner router name
  bool popUntil(String innerName) {
    if (_innerRouters.length <= 1) return false;
    
    final index = _innerRouters.indexWhere(
      (element) => element.routerName == innerName
    );
    
    if (index >= 0 && index < _innerRouters.length - 1) {
      // ✅ Dispose routers that will be removed
      final routersToRemove = _innerRouters.sublist(index + 1);
      for (final router in routersToRemove) {
        router.dispose();
      }
      _innerRouters.length = index + 1;
      return true;
    }
    return false;
  }
  
  /// ✅ Find inner router by name efficiently
  BaseRouter? findInnerRouter(String routerName) {
    return _innerRouters.firstWhereOrNull(
      (element) => element.routerName == routerName
    );
  }
  
  /// ✅ Remove specific inner router by name
  bool removeInnerRouter(String routerName) {
    final index = _innerRouters.indexWhere(
      (element) => element.routerName == routerName
    );
    
    if (index >= 0) {
      final removed = _innerRouters.removeAt(index);
      removed.dispose();
      return true;
    }
    return false;
  }
  
  /// ✅ Check if inner router exists
  bool hasInnerRouter(String routerName) {
    return _innerRouters.any((element) => element.routerName == routerName);
  }
}

// ✅ Improved list extension with better performance
extension ConvertBaseRouter on List<BaseRouter> {
  /// Convert to MaterialPage list with caching
  List<MaterialPage> getMaterialPage() {
    // ✅ Use map directly without toList() for better performance
    return map((element) => element.getRouter()).toList(growable: false);
  }

  /// Get router by name with early termination
  BaseRouter? getByName(String routerName) {
    return firstWhereOrNull((element) => element.routerName == routerName);
  }
  
  /// ✅ Batch operations for better performance
  void disposeAll() {
    for (final router in this) {
      router.dispose();
    }
    clear();
  }
  
  /// ✅ Find multiple routers by pattern
  List<BaseRouter> findRoutersByPattern(bool Function(BaseRouter) predicate) {
    return where(predicate).toList();
  }
  
  /// ✅ Get router names efficiently
  List<String> getRouterNames() {
    return map((router) => router.routerName).toList(growable: false);
  }
  
  /// ✅ Validate router list (no duplicate names)
  bool validateRouters() {
    final names = <String>{};
    for (final router in this) {
      if (!names.add(router.routerName)) {
        return false; // Duplicate found
      }
    }
    return true;
  }
}

// /// ✅ Router builder utility for common patterns
// class RouterBuilder {
//   static BaseRouter createSimpleRouter({
//     required String name,
//     required Widget Function() widget,
//     String? parentName,
//     dynamic arguments,
//   }) {
//     return BaseRouter(
//       routerName: name,
//       widget: widget,
//       parentName: parentName,
//       arguments: arguments,
//     );
//   }
  
//   static BaseRouter createRouterWithInners({
//     required String name,
//     required Widget Function() widget,
//     required List<BaseRouter> innerRouters,
//     String? parentName,
//     dynamic arguments,
//   }) {
//     final router = BaseRouter(
//       routerName: name,
//       widget: widget,
//       parentName: parentName,
//       arguments: arguments,
//     );
    
//     for (final inner in innerRouters) {
//       router.addInner(inner);
//     }
    
//     return router;
//   }
// }