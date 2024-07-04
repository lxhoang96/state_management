final class RoutePathConfigure {
  final String? _pathName;
  final bool _isUnknown;
  final bool _lostConnected;

  RoutePathConfigure.home()
      : _pathName = null,
        _lostConnected = false,
        _isUnknown = false;

  RoutePathConfigure.otherPage(this._pathName)
      : _isUnknown = false,
        _lostConnected = false;
  RoutePathConfigure.unKnown()
      : _pathName = null,
        _lostConnected = false,
        _isUnknown = true;

  RoutePathConfigure.lostConnected()
      : _pathName = null,
        _isUnknown = false,
        _lostConnected = true;

  bool get isHomePage => _pathName == null;

  bool get isOtherPage => _pathName != null;

  bool get isUnknown => _isUnknown == true;
  bool get lostConnected => _lostConnected == true;

  String? get pathName => _pathName;
}
