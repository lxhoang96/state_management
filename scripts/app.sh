#!/bin/bash
if [ ! -d 'lib' ]; then
exit 'no lib folder'
else
cd lib

mkdir app
cd app
mkdir client
cd client
mkdir helper
mkdir interceptors
mkdir local
 
cd ..
mkdir features
mkdir navigation
cd navigation
touch app_routers.dart
touch router_names.dart

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