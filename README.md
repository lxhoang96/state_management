<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->


# Features

1. State management
- Auto dispose controller, observer

2. Navigation without context

3. Custom dialog, snackbar 
- Dialog, snackbar are not in navigation tree

# Used


1. In main.dart, add MainWidget
## Navigation 1.0
```
GlobalState(
  initBinding: InitBindingImpl(),
  useLoading: true,
  appIcon: AssetImage('app_icon'),
  // initialRoute: RouterName.landing,
  backgroundImage: DecorationImage(
      image: AssetImage('background'),
      fit: BoxFit.fill),
  child:  child!,
),
```
## Navigation 2.0
```
MaterialApp.router(
  routerDelegate: HomeRouterDelegate(
    listPages: listPages,
    // globalWidgets: [UserInteractionWidget()],
    homeRouter: RouterName.landing,
    initBinding: InitBindingImpl(),
    appIcon: AppImages.landingImg('icon_robot'),
    backgroundImage: DecorationImage(
        image: AssetImage(AppImages.img('background')), fit: BoxFit.fill),
  ),

  routeInformationParser: HomeRouteInformationParser(),
```

2. Add app level controllers
```
class InitBindingImpl extends InitBinding {
  @override
  Future dependencies() async {
    Global.add(HttpHelper());
    Global.add<AuthenticationRepository>(AuthenticationUsecases());
    Preferences.init();
  }
}
```

3. Navigation in App with routers:
## Navigation 1.0
```
initialRoute: RouterName.appControl,
routes: routes,
```
## Navigation 2.0
```
listPages: listPages,
homeRouter: RouterName.landing,
```

4. Creates controllers for each router
```
class HomeController extends DefaultController

  @override
  init(){

  }

  @override
  dispose(){

  }
```

5. Add, find controller with GlobalState
```
Global.add(HomeController());
Global.find<HomeController>();
```

6. Create Observer to listen value changed
```
final index = Observer(initValue: 0);
index.value = 1; //update value
```
7. Stream subcribe with ObserWidget and ObserListWidget in Widget tree

```
// listen single value
ObserWidget(
  value: controller.index,
  child: (value) {
    if (value != null) {
      return Text(index.toString());
    }
    return const SizedBox();
  },
)
```

```
// listen multiple values

ObserListWidget(
  listStream: [
    Observer(initValue: 0).stream,
    Observer(initValue: 1).stream,
  ],
  child: (value) {
    final int index1 = value[0];
    final int index2 = value[1];
    return Text('$index1: $index2');
  }
)
```

Or not: 
```
// listen without return Widget
final combinedStream = ObserverCombined([
  stream,
  stream1,
  stream2
]);
combinedStream.value.listen((streams) {
  final String _stream = streams[0];
  final String _stream1 = streams[1];
  final String _stream2 = streams[2];
  return Text(_stream + _stream1 + _stream2);
});
```

# Additional information

Pure Dart package depended on rxdart version


# Auto generate template scripts
1. Generate code for feature-first & Clean architecture project
- app.sh: script generate app level folder
- feature.sh: script generate feature level
