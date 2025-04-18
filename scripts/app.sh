#!/bin/bash
if [ ! -d 'lib' ]; then
exit 'no lib folder'
else
cd lib

mkdir app
cd app
mkdir global_controllers
mkdir network
cd network
mkdir helper
mkdir interceptors
mkdir local
mkdir urls
cd urls
touch api_endpoints.dart
touch roots.dart
echo "
const String baseUrl = 'localhost:9000';
" >> roots.dart
echo "
class AppEndPoint {
  static const register = 'user/register';
  static const login = 'user/login';
}
" >> api_endpoints.dart
cd ..
 
cd ..
mkdir features
mkdir navigation
cd navigation
touch app_routers.dart
touch router_names.dart

echo "
class RouteName {
  static const landing = '/';
}
">> router_names.dart

echo "
import 'package:base/base_navigation.dart';

Map<String, InitRouter> listPages = {
 // RouterName.landing: InitRouter(widget: () => LandingScreen()),
};
" >> app_routers.dart
cd ..
cd ..

mkdir cores
cd cores
mkdir constant
mkdir extensions
mkdir theme
cd theme
touch app_theme.dart
mkdir src
cd src
touch app_color.dart
touch app_font.dart
touch app_image.dart
touch app_size.dart
cd ..
cd ..

fi