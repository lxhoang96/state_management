import 'package:base/base_component.dart';
import 'package:flutter/material.dart';

import 'package:example/routers/router_name.dart';
import 'package:example/screen1/screen1_ctrl.dart';

class Screen1 extends StatelessWidget {
  Screen1({super.key});
  final controller = Global.add(Screen1Controller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ObserWidget(
            value: controller.intObs,
            child: (value) => Text(
              value.toString(),
            ),
          ),
          TextField(
            controller: controller.textCtrl,
            onChanged: (value) {
              controller.intObs.value++;
            },
          ),
          TextButton(
              onPressed: () {
                // AppRouter.pushNamed(RouteName.screen2);
                controller.intObs.value++;
                Global.pushNamed(RouteName.screen2);
              },
              child: const Text('To screen 2')),
        ],
      ),
    );
  }
}
