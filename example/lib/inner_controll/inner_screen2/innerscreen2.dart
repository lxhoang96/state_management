import 'package:base/base_component.dart';
import 'package:example/inner_controll/inner_screen2/innerscreen2_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';

class InnerScreen2 extends StatelessWidget {
  InnerScreen2({super.key});
  final controller = Global.add(InnerScreen2Controller());
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
            onPressed: () {
              Global.pushNamed(RouteName.screen3);
            },
            child: const Text('To screen 3')),
      ],
    );
  }
}
