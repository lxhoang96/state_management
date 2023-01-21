class RoutePathConfigure {
  final String? _pathName;
  final bool _isUnknown;

  RoutePathConfigure.home()
      : _pathName = null,
        _isUnknown = false;

  RoutePathConfigure.otherPage(this._pathName) : _isUnknown = false;
  RoutePathConfigure.unKnown()
      : _pathName = null,
        _isUnknown = true;

  bool get isHomePage => _pathName == null;

  bool get isOtherPage => _pathName != null;

  bool get isUnknown => _isUnknown == true;

  String? get pathName => _pathName;
}
