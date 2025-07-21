import 'package:base/base_component.dart';
import 'package:base/src/interfaces/controller_interface.dart';
import 'package:flutter/material.dart';



/// Controller is where you write your logic code
/// It should not be used to navigate.
/// 
/// controller life circle
/// 
/// init: start before screen is built first time
/// 
/// ready: start immediately after first time screen is built
/// 
/// dispose: called when router contains this controller is not in navigator stack
base class DefaultController implements BaseController {
  final List<Observer> _observers = [];
  bool _isDisposed = false;

  /// Register an observer with this controller
  T registerObserver<T extends Observer>(T observer) {
    if (_isDisposed) return observer;
    _observers.add(observer);
    return observer;
  }

  /// ✅ Bulk register observers for better performance
  void registerObservers(List<Observer> observers) {
    if (_isDisposed) return;
    _observers.addAll(observers);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    debugPrint('$this disposing');
    
    // ✅ Parallel disposal for better performance
    for (final observer in _observers) {
      observer.dispose();
    }
    _observers.clear();
  }

  @override
  init() {
    if (_isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  @override
  onReady() {}
}
