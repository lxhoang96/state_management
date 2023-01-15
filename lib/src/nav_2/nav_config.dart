class RoutePathConfigure {
  final String? _pathName;
  final bool _isUnknown;
  // final bool _isInner;

  RoutePathConfigure.home()
      : _pathName = null,
        // _isInner = false,
        _isUnknown = false;

  // RoutePathConfigure.innerPage(this._pathName) : _isUnknown = false;
  // // _isInner = true;
  // RoutePathConfigure.outerPage(this._pathName) : _isUnknown = false;
  // _isInner = false;
  RoutePathConfigure.otherPage(this._pathName) : _isUnknown = false;
  RoutePathConfigure.unKnown()
      : _pathName = null,
        // _isInner = false,
        _isUnknown = true;

  bool get isHomePage => _pathName == null;
  // bool get isOuterPage => _pathName != null ;
  // bool get isInnerPage => _pathName != null;
  bool get isOtherPage => _pathName != null;

  bool get isUnknown => _isUnknown == true;
  String? get pathName => _pathName;
}
