import 'package:base/base_component.dart';
import 'package:flutter/material.dart';
import 'package:test_newrouter/routers/router_name.dart';
import 'package:test_newrouter/screen3/screen3_ctrl.dart';

class Screen3 extends StatelessWidget {
  Screen3({super.key});
  final controller = Global.add(Screen3Controller());

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
              // AppRouter.popUntilNamed(RouteName.screen1);
              Global.popAllAndPushNamed(RouteName.screen1);
            },
            child: const Text('To screen 1')),
      ],
    ));
  }
}
