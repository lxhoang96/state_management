import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';
import 'package:example/screen1/screen1.dart';
import 'package:example/screen2/screen2.dart';
import 'package:example/screen3/screen3.dart';

Map<String, Widget Function(BuildContext)> routes = {
  RouteName.screen1: (p0) => Screen1(),
  RouteName.screen2: (p0) => Screen2(),
  RouteName.screen3: (p0) => Screen3(),
};
