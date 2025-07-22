import 'dart:async';

import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/interfaces/widget_interfaces.dart';
import 'package:flutter/material.dart';

final class SnackBarController implements SnackbarInterface {
  static final instance = SnackBarController._();
  SnackBarController._();
  
  final snackbars = InnerObserver<List<_SnackbarItem>>(initValue: []); // ✅ Use custom item class
  final Map<String, Timer> _timers = {}; // ✅ Track timers for better cleanup

  @override
  showSnackbar({
    required SnackBarStyle style,
    required String? message,
    required String title,
    Function()? onTap,
    int timeout = 2,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final snackbar = _buildSnackbar(
      style: style,
      message: message,
      title: title,
      onTap: onTap,
      id: id,
    );
    
    // ✅ Add with unique ID
    final item = _SnackbarItem(id: id, widget: snackbar);
    snackbars.value.add(item);
    snackbars.update();
    
    // ✅ Auto-remove with cleanup
    _scheduleRemoval(id, timeout);
  }

  @override
  showCustomSnackbar({required Widget child, int timeout = 2}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = _SnackbarItem(id: id, widget: child);
    
    snackbars.value.add(item);
    snackbars.update();
    
    _scheduleRemoval(id, timeout);
  }
  
  @override
  void dissmissSnackbar({Function? onClosed}) {
    if (snackbars.value.isNotEmpty) {
      // ✅ Clean up all timers
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
      
      snackbars.value.clear();
      snackbars.update();
      onClosed?.call();
    }
  }

  // ✅ Remove specific snackbar
  void removeSnackbar(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    
    snackbars.value.removeWhere((item) => item.id == id);
    snackbars.update();
  }

  // ✅ Schedule removal with cleanup
  void _scheduleRemoval(String id, int timeout) {
    _timers[id]?.cancel(); // Cancel existing timer
    _timers[id] = Timer(Duration(seconds: timeout), () {
      removeSnackbar(id);
    });
  }

  // ✅ Optimized snackbar builder
  Widget _buildSnackbar({
    required SnackBarStyle style,
    required String? message,
    required String title,
    Function()? onTap,
    required String id,
  }) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: onTap != null
            ? HitTestBehavior.deferToChild
            : HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: style.backgroundColor.withAlpha(50),
                offset: const Offset(5.0, 5.0),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
            color: style.backgroundColor.withAlpha(200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (message != null)
                      Text(
                        message,
                        style: TextStyle(
                          color: style.textColor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              // ✅ Add close button
              GestureDetector(
                onTap: () => removeSnackbar(id),
                child: Icon(
                  Icons.close,
                  color: style.textColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Helper class for better snackbar management
class _SnackbarItem {
  final String id;
  final Widget widget;
  
  _SnackbarItem({required this.id, required this.widget});
}

final class SnackBarStyle {
  const SnackBarStyle(this.backgroundColor, this.textColor);
  final Color backgroundColor;
  final Color textColor;

  SnackBarStyle.success()
      : backgroundColor = const Color.fromARGB(255, 75, 181, 67),
        textColor = Colors.white;
  SnackBarStyle.warning()
      : backgroundColor = const Color.fromARGB(255, 255, 204, 0),
        textColor = Colors.white;
  SnackBarStyle.failed()
      : backgroundColor = const Color(0xffee0033),
        textColor = Colors.white;
}