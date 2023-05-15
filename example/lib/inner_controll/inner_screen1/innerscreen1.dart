import 'package:base/base_component.dart';
import 'package:example/inner_controll/inner_screen1/innerscreen1_ctrl.dart';
import 'package:flutter/material.dart';

class InnerScreen1 extends StatelessWidget {
  InnerScreen1({super.key});
  final controller = Global.add(InnerScreen1Controller());
  @override
  Widget build(BuildContext context) {
    return Column(
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
                controller.intObs.value++;
                Global.pop();
              },
              child: const Text('To screen 2')),
        ],
      
    );
  }
}
