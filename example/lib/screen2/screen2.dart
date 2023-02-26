import 'package:base/base_component.dart';
import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';
import 'package:example/screen2/screen2_ctrl.dart';

class Screen2 extends StatelessWidget {
  Screen2({super.key});
  final controller = Global.add(Screen2Controller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ObserWidget(
          value: controller.controller1.intObs,
          child: (value) => Text(
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
