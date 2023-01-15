#!/bin/bash

x="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
mkdir $1
cd $1
mkdir src
cd src
mkdir presentation
cd presentation
mkdir screens
cd screens
mkdir $1_main
cd $1_main
touch $1_screen.dart
touch $1_controller.dart
echo "import 'package:flutter/material.dart';
import 'package:base/base_component.dart';
import '$1_controller.dart';

class ${x}Screen extends StatelessWidget {
 ${x}Screen({super.key});
 final controller = Global.add(${x}Controller());

 @override
 Widget build(BuildContext context) {
   return Container();
 }
}" >> $1_screen.dart
echo "import 'package:base/base_component.dart';

class ${x}Controller extends DefaultController{

}" >> $1_controller.dart
cd ..
cd ..
mkdir widgets
cd ..
mkdir domain
cd domain
mkdir entities
mkdir enum
mkdir repositories
mkdir usecases
cd ..
mkdir data
cd data
mkdir helpers
cd ..
cd ..
touch $1_export.dart
echo //export your classes here >> $1_export.dart