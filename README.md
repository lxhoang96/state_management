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

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

1. State management
- Auto dispose controller, observer

2. Navigation without context

3. Custom dialog, snackbar 
- Dialog, snackbar is not in navigator tree

## Used

1. In main.dart, add MainWidget
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
```
initialRoute: RouterName.appControl,
routes: routes,
```

4. Creates controllers for each router
```
class HomeController extends DefaultController
@override
init(){}
@override
dispose(){}
```

5. Add, find controller with GlobalState
```
Global.add(HomeController());
Global.find<HomeController>();
```

6. Create Observer to listen value changed
```
final index = Observer(initValue: 0);
```

## Additional information

Pure Dart package depended on rxdart version


## Future planning
1. Generate code for feature-first & Clean architecture project