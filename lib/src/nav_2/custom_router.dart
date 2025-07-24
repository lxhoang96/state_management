import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../base_component/base_observer.dart';

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
/// String [routerName] and inner navigation stream control
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
  
  // ✅ Only one stream controller for MaterialPages - this is what UI needs
  final  _innerPageController = InnerObserver<List<MaterialPage>>(
    initValue: [],
  );
  
  // ✅ Internal list to track routers - not exposed via stream
  final List<BaseRouter> _innerRouters = [];
  
  BaseRouter({
    required this.routerName,
    required Widget Function() widget,
    this.parentName,
    this.arguments,
    this.argumentNav,
  }) : _widget = widget;

  // ✅ Getter for inner routers (read-only)
  List<BaseRouter> get innerRouters => List.unmodifiable(_innerRouters);
  
  // ✅ Check if router has inner routes
  bool get hasInnerRouters => _innerRouters.isNotEmpty;
  
  // ✅ Get inner router count efficiently
  int get innerRouterCount => _innerRouters.length;
  
  // ✅ Get current inner router
  BaseRouter? get currentInnerRouter => _innerRouters.isNotEmpty ? _innerRouters.last : null;
  
  // ✅ Get inner stream for MaterialPages - this is what AppNav will use
  InnerObserver<List<MaterialPage>>? get innerStream => _innerPageController;

  MaterialPage _createPage() {
    return MaterialPage(
      child: _widget(),
      name: routerName,
      key: _key,
      arguments: arguments,
    );
  }

  MaterialPage getRouter() {
    if (_cachedPage == null || _isPageInvalidated) {
      _cachedPage = _createPage();
      _isPageInvalidated = false;
    }
    return _cachedPage!;
  }
  
  // ✅ Generate MaterialPages from inner routers
  List<MaterialPage> _getInnerMaterialPages() {
    return _innerRouters
        .map((router) => router.getRouter())
        .toList(growable: false);
  }
  
  // ✅ Update inner stream with current MaterialPages
  void _updateInnerStream() {
    _innerPageController.value = _getInnerMaterialPages();
  }
  
  void invalidatePage() {
    _isPageInvalidated = true;
  }
  
  void dispose() {
    _cachedPage = null;
    
    // Dispose all inner routers
    for (final router in _innerRouters) {
      router.dispose();
    }
    _innerRouters.clear();
    
    _innerPageController.dispose();
  }
}

// ✅ Updated extension to work with single stream
extension BaseRouterExtension on BaseRouter {
  /// Add inner router with validation
  bool addInner(BaseRouter innerRouter) {
    // Prevent duplicate router names
    if (_innerRouters.any((router) => router.routerName == innerRouter.routerName)) {
      return false;
    }
    
    _innerRouters.add(innerRouter);
    
    _updateInnerStream();
    return true;
  }
  
  /// Pop last inner router
  BaseRouter? popInner() {
    if (_innerRouters.length <= 1) return null;
    
    final removed = _innerRouters.removeLast();
    _updateInnerStream();
    
    removed.dispose();
    return removed;
  }

  /// Pop all and push new inner router
  void popAllAndPushInner(BaseRouter innerRouter) {
    // Dispose all existing routers
    for (final router in _innerRouters) {
      router.dispose();
    }
    _innerRouters.clear();
    _innerRouters.add(innerRouter);
    
    _updateInnerStream();
  }

  /// Pop last and add new inner router
  void popAndAddInner(BaseRouter innerRouter) {
    if (_innerRouters.isNotEmpty) {
      final removed = _innerRouters.removeLast();
      removed.dispose();
    }
    
    _innerRouters.add(innerRouter);
    _updateInnerStream();
  }

  /// Pop until specific inner router name
  bool popUntil(String innerName) {
    if (_innerRouters.length <= 1) return false;
    
    final index = _innerRouters.indexWhere(
      (element) => element.routerName == innerName
    );
    
    if (index >= 0 && index < _innerRouters.length - 1) {
      final routersToRemove = _innerRouters.sublist(index + 1);
      
      // Dispose routers that will be removed
      for (final router in routersToRemove) {
        router.dispose();
      }
      
      _innerRouters.length = index + 1;
      _updateInnerStream();
      return true;
    }
    return false;
  }
  
  /// Find inner router by name efficiently
  BaseRouter? findInnerRouter(String routerName) {
    return _innerRouters.firstWhereOrNull(
      (element) => element.routerName == routerName
    );
  }
  
  /// Remove specific inner router by name
  bool removeInnerRouter(String routerName) {
    final index = _innerRouters.indexWhere(
      (element) => element.routerName == routerName
    );
    
    if (index >= 0) {
      final removed = _innerRouters.removeAt(index);
      _updateInnerStream();
      removed.dispose();
      return true;
    }
    return false;
  }
  
  /// Check if inner router exists
  bool hasInnerRouter(String routerName) {
    return _innerRouters.any((element) => element.routerName == routerName);
  }
  
  /// Enhanced pop method that handles inner navigation priority
  bool pop() {
    // If has inner routers, pop from inner first
    if (hasInnerRouters && _innerRouters.length > 1) {
      return popInner() != null;
    }
    return false; // Can't pop this router itself
  }
}