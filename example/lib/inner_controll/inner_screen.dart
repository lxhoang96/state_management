import 'package:base/base_component.dart';
import 'package:base/base_navigation.dart';
import 'package:example/inner_controll/inner_controller.dart';
import 'package:example/routers/router_name.dart';
import 'package:flutter/material.dart';

class InnerScreen extends StatelessWidget {
  InnerScreen({super.key});
  final controller = Global.add(InnerController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Router(
        routerDelegate: InnerDelegateRouter(
            initInner: RouteName.inner1, parentName: RouteName.innerControll),
        routeInformationParser: HomeRouteInformationParser(),
      ),
      bottomNavigationBar: SizedBox(
        height: 150,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: InkWell(
                      onTap: () => controller.navigateInner[0].call(),
                      child: const Text('Screen0'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: InkWell(
                      onTap: () => controller.navigateInner[1].call(),
                      child: const Text('Screen1'),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
