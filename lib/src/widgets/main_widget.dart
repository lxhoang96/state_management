import 'package:base/base_component.dart';
import 'package:base/base_navigation.dart';
import 'package:base/base_widget.dart';
import 'package:flutter/material.dart';

class GlobalState extends StatefulWidget {
  const GlobalState(
      {Key? key,
      required this.child,
      this.init,
      required this.appIcon,
      required this.initialRoute})
      : super(key: key);
  final Widget child;
  final InitBinding? init;
  final String appIcon;
  final String? initialRoute;
  @override
  State<GlobalState> createState() => _GlobalStateState();
}

class _GlobalStateState extends State<GlobalState> {
  bool init = false;
  @override
  void initState() {
    AppLoading.showing.value = false;
    AppSnackBar.showSnackBar.value = false;

    if (widget.init == null) {
      setState(() {
        init = true;
      });
    } else {
      widget.init?.dependencies().then((value) => setState(() {
            init = true;
          }));
    }
    if (widget.initialRoute != null) {
      AppRouter.listActiveRouter.add(widget.initialRoute!);
    }

    super.initState();
  }

  @override
  void dispose() {
    Global.disposeAll();
    super.dispose();
  }

  Widget buildChild() {
    if (init) {
      return SizedBox.expand(child: widget.child);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildChild(),
        Positioned.fill(
          child: ObserWidget(
            value: AppLoading.showing,
            child: (value) {
              if (value == true) {
                return AppLoading.loadingWidget(widget.appIcon);
              }
              return const SizedBox();
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: ObserWidget(
              value: AppSnackBar.showSnackBar,
              child: (value) {
                if (value == true) {
                  return AppSnackBar.snackbar;
                }
                return const SizedBox();
              }),
        )
      ],
    );
  }
}

abstract class InitBinding {
  Future dependencies();
}
