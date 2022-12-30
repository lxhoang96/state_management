class HomeRoutePath {
  final String? _pathName;
  final bool _isUnknown;
  final bool _isInner;

  HomeRoutePath.home()
      : _pathName = null,
        _isInner = false,
        _isUnknown = false;

  HomeRoutePath.innerPage(this._pathName)
      : _isUnknown = false,
        _isInner = true;
  HomeRoutePath.outerPage(this._pathName)
      : _isUnknown = false,
        _isInner = false;

  HomeRoutePath.unKnown()
      : _pathName = null,
        _isInner = false,
        _isUnknown = true;

  bool get isHomePage => _pathName == null;
  bool get isOuterPage => _pathName != null && _isInner == false;
  bool get isInnerPage => _pathName != null && _isInner == true;
  bool get isUnknown => _isUnknown == true;
  String? get pathName => _pathName;
}
