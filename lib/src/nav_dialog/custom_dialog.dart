import 'package:flutter/material.dart';

/// This is just a utility class for creating custom dialog styles
/// Not a singleton - just style/UI helpers
class CustomDialogStyles {
  
  static Widget createStyledDialog({
    required Widget child,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Function? onBarrierTap,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.black.withAlpha(90),
      body: Stack(
        children: [
          // Barrier
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (barrierDismissible) {
                onBarrierTap?.call();
              }
            },
          ),
          // Dialog content
          Align(
            alignment: Alignment.center,
            child: child,
          ),
        ],
      ),
    );
  }

  static Widget createBottomSheetDialog({
    required Widget child,
    Color? backgroundColor,
  }) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(90),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: child,
        ),
      ),
    );
  }
}