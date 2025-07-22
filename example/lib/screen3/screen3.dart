import 'package:base/base_component.dart';
import 'package:flutter/material.dart';
import 'package:example/routers/router_name.dart';
import 'package:example/screen3/screen3_ctrl.dart';

class Screen3 extends StatelessWidget {
  Screen3({super.key});
  final controller = Global.add(Screen3Controller());

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
              // AppRouter.popUntilNamed(RouteName.screen1);
              Global.popUntil(RouteName.screen1);
            },
            child: const Text('To screen 1')),
      ],
    ));
  }
}
