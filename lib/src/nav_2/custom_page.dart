// import 'package:flutter/material.dart';

// class CustomPage extends MaterialPage {
//   const CustomPage(
//       {required super.child,
//       required super.name,
//       required super.key,
//       this.subPages = const []});

//   final List<CustomPage> subPages;
// }

// extension PageExtension on CustomPage {
//   update(CustomPage newValue) => newValue;

//   add(CustomPage newValue) {
//     subPages.add(newValue);
//   }

//   back() {
//     if (subPages.length <= 1) return false;
//     subPages.removeLast();
//     return true;
//   }

//   backUntil(String checkValue) {
//     if (subPages.length <= 1) return false;
//     final index = subPages.indexWhere((element) => element.name == checkValue);
//     subPages.removeRange(index, subPages.length);
//     return true;
//   }

//   backUntilAndAdd(String checkValue, CustomPage newValue) {
//     final canBack = backUntil(checkValue);
//     if (!canBack) return false;
//     subPages.add(newValue);
//   }
// }
