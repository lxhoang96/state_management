abstract class AppNavInterfaces {
  /// push a page
  void pushNamed(String routerName, {String? parentName});

  /// remove last page
  void pop();

  /// remove several pages until page with routerName
  void popUntil(String routerName);

  /// remove last page and replace this with new one
  void popAndReplaceNamed(String routerName, {String? parentName});

  /// remove all and add a page
  void popAllAndPushNamed(String routerName);

  dynamic get argument;
}
