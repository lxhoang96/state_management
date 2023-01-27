import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// It is where your navigator flow starts.
/// Each [InitPage] present a page later.
/// It contains a function return Widget, [argument] and [parentName] (optional)
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

/// A BasePage extends InitPage to return a Page with
/// String [routerName] and List of BasePage [innerPages] (optional)
class BasePage extends InitPage {
  final String routerName;
  MaterialPage? page;
  final List<BasePage> innerPages = [];
  BasePage({
    required this.routerName,
    required super.widget,
    super.parentName,
    super.argument,
  });

  MaterialPage _initPage() {
    return MaterialPage(
        child: widget(),
        name: routerName,
        key: ValueKey(routerName),
        arguments: argument);
  }

  MaterialPage getPage() {
    page ??= _initPage();
    return page!;
  }
}

extension BasePageExtension on BasePage {
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
