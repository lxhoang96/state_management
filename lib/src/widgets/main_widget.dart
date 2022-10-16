import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/widgets/custom_dialog.dart';
import 'package:base/src/widgets/custom_snackbar.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

class GlobalState extends StatefulWidget {
  const GlobalState(
      {Key? key, required this.child, this.init, required this.appIcon})
      : super(key: key);
  final Widget child;
  final InitBinding? init;
  final String appIcon;
  @override
  State<GlobalState> createState() => _GlobalStateState();
}

class _GlobalStateState extends State<GlobalState> {
  bool init = false;
  @override
  void initState() {
    widget.init?.dependencies().then((value) => setState(() {
          init = true;
        }));

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
            value: AppDialog.showing,
            child: (value) {
              if (value == true) {
                return AppDialog.showDialog(widget.appIcon);
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
