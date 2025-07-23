import 'dart:async';

import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/nav_2/custom_router.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_config.dart';


/// Delegate for nested navigation.
final class InnerDelegateRouter extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  final List<NavigatorObserver> observers;
  final Map<String, InitRouter> listPages;
  final String parentName;
  final String initInner;
  
  // ✅ Cache the navigator key to avoid recreation
  late final GlobalKey<NavigatorState> _navigatorKey;
  
  // ✅ Stream subscription for proper disposal
  StreamSubscription<List<MaterialPage>>? _streamSubscription;
  
  // ✅ Disposal flag to prevent operations after disposal
  // bool _isDisposed = false;
  
  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  InnerDelegateRouter({
    required this.parentName,
    required this.listPages,
    required this.initInner,
    this.observers = const [],
  }) : _navigatorKey = GlobalObjectKey<NavigatorState>('inner_$parentName') {
    _initialize();
  }

  // ✅ Separate initialization method for better error handling
  void _initialize() {
    try {
      MainState.instance.setInitRouters(listPages);
      MainState.instance.setInitInnerRouter(initInner, parentName);
      
      final stream = MainState.instance.innerStream(parentName);
      if (stream != null) {
        _streamSubscription = stream.stream.listen(
          _onPagesChanged,
          onError: _onStreamError,
        );
        _onPagesChanged(stream.value);
      } else {
        debugPrint('Warning: No inner stream found for parent: $parentName');
      }

    } catch (e) {
      debugPrint('Error initializing InnerDelegateRouter: $e');
    }
  }

  List<Page> _pages = [];
  
  // ✅ Optimized page change handler
  void _onPagesChanged(List<MaterialPage> value) {
    // if (_isDisposed) return;
    
    // ✅ More efficient list comparison - check length first
    if (_pages.length != value.length || !listEquals(_pages, value)) {
      _pages = List.from(value); // ✅ Create new list to avoid reference issues
      // if (!_isDisposed) {
        notifyListeners();
      // }
    }
  }
  
  // ✅ Error handler for stream
  void _onStreamError(Object error) {
    debugPrint('InnerDelegateRouter stream error: $error');
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Early return for empty pages
    if (_pages.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      observers: observers,
      onDidRemovePage: _onPageRemoved,
    );
  }

   // ✅ Proper disposal
  @override
  void dispose() {
    // if (_isDisposed) return;
    // _isDisposed = true;
    
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _pages.clear();
    
    super.dispose();
  }
  
  // ✅ Separate page removal handler
  void _onPageRemoved(Page page) {
    // if (_isDisposed) return;
    
    try {
      if (page.name != null) {
        debugPrint('Inner page removed: ${page.name} (parent: $parentName)');
      }
      // MainState.instance.pop();
    } catch (e) {
      debugPrint('Error removing page: $e');
    }
  }

  @override
  Future<void> setNewRoutePath(RoutePathConfigure configuration) async {
    // if (_isDisposed) return;

    if (!kIsWeb) return;

    if (configuration.isUnknown) {
      MainState.instance.showUnknownRouter();
      return;
    }

    if (configuration.pathName != null || configuration.pathName != homePath) {
       // ✅ Add proper web navigation handling
        _handleWebNavigation(configuration);
      return;
    }
    MainState.instance.showHomeRouter();
  }

  // ✅ Separate web navigation handling
  void _handleWebNavigation(RoutePathConfigure configuration) {
    // ✅ More robust path parsing
    final pathName = configuration.pathName;
    if (pathName == null) return;
    
    final parts = pathName.split('/');
    if (parts.length > 1) {
      final valuePart = parts.firstWhere(
        (part) => part.startsWith('value:'),
        orElse: () => '',
      );
      
      if (valuePart.isNotEmpty) {
        final innerPaths = valuePart.substring(6).split('/'); // Remove 'value:'
        MainState.instance.setInnerPagesForWeb(parentName: parentName, listRouter: innerPaths);
      }
    }
  }
}
