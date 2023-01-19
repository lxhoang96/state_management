import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class InitPage {
  final Widget Function() widget;
  final dynamic argument;
  final String? parentName;
  InitPage({
    required this.widget,
    this.parentName,
    this.argument,
  });
  BasePage toBasePage(String routerName) {
    return BasePage(
      routerName: routerName,
      widget: widget,
      parentName: parentName,
      argument: argument,
    );
  }
}

class BasePage extends InitPage {
  final String routerName;
  final List<BasePage> innerPages = [];
  BasePage({
    required this.routerName,
    required super.widget,
    super.parentName,
    super.argument,
  });
}

extension BasePageExtension on BasePage {
  MaterialPage getPage() {
    return MaterialPage(
        child: widget(),
        name: routerName,
        key: ValueKey(routerName),
        arguments: argument);
  }

  addInner(BasePage innerPage) => innerPages.add(innerPage);
  bool pop() {
    if (innerPages.length <= 1) return false;
    innerPages.removeLast();
    return true;
  }

  void popAllAndPushInner(BasePage innerPage) => innerPages
    ..clear()
    ..add(innerPage);

  void popAndAddInner(BasePage innerPage) {
    if (innerPages.isNotEmpty) {
      innerPages.removeLast();
    }

    innerPages.add(innerPage);
  }

  bool popUntil(String innerName) {
    if (innerPages.length <= 1) return false;
    final index =
        innerPages.indexWhere((element) => element.routerName == innerName);
    if (index > 0) {
      innerPages.length = index;
      return true;
    }
    return false;
  }
}

extension ConvertBasePage on List<BasePage> {
  List<MaterialPage> getMaterialPage() {
    final List<MaterialPage> pages = [];
    forEach((element) {
      pages.add(element.getPage());
    });
    return pages;
  }

  BasePage? getByName(String routerName) =>
      firstWhereOrNull((element) => element.routerName == routerName);
}
