
abstract class BaseController {
  init();

  void dispose();
}

class DefaultController extends BaseController {
  DefaultController({this.instance});
  // {
  //    init();
  // }
  final dynamic instance;
  @override
  void dispose() {}

  @override
  init() {}
}
