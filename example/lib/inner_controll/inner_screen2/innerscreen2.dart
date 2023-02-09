import 'package:base/base_component.dart';
import 'package:example/inner_controll/inner_screen2/innerscreen2_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';

class InnerScreen2 extends StatelessWidget {
  InnerScreen2({super.key});
  final controller = Global.add(InnerScreen2Controller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ValueListenableBuilder(
          valueListenable: controller.controller1.intObs,
          builder: (context, value, widget) => Text(
            value.toString(),
          ),
        ),
        TextField(
          controller: controller.textCtrl,
          onChanged: (value) {
            controller.controller1.intObs.value++;
          },
        ),
        TextButton(
            onPressed: () {
              controller.controller1.intObs.value++;
              // AppRouter.pushNamed(RouteName.screen3);
              Global.pushNamed(RouteName.screen3);
            },
            child: const Text('To screen 3')),
      ],
    ));
  }
}
