import 'package:base/base_component.dart';
import 'package:base/base_widget.dart';
import 'package:flutter/material.dart';

class GlobalState extends StatefulWidget {
  const GlobalState(
      {Key? key,
      required this.child,
      this.initBinding,
      this.appIcon,
      this.useLoading = true,
      this.useSnackbar = true,
      this.isDesktop = true,
      this.backgroundImage})
      : super(key: key);
  final Widget child;
  final InitBinding? initBinding;
  final String? appIcon;
  final bool useLoading;
  final bool useSnackbar;
  final bool isDesktop;
  final DecorationImage? backgroundImage;
  @override
  State<GlobalState> createState() => _GlobalStateState();
}

class _GlobalStateState extends State<GlobalState> {
  bool didInit = false;
  @override
  void initState() {
    AppLoading.showing.value = false;
    AppSnackBar.showSnackBar.value = false;

    if (widget.initBinding == null) {
      setState(() {
        didInit = true;
      });
    } else {
      widget.initBinding?.dependencies().then((value) => setState(() {
            didInit = true;
          }));
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildChild() {
    if (didInit) {
      return Container(
          decoration: BoxDecoration(image: widget.backgroundImage),
          child: widget.child);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildChild(),
        widget.useLoading
            ? Positioned.fill(
                child: ObserWidget(
                  value: AppLoading.showing,
                  child: (value) {
                    if (value == true) {
                      return AppLoading.loadingWidget(widget.appIcon);
                    }
                    return const SizedBox();
                  },
                ),
              )
            : const SizedBox(),
        widget.useSnackbar
            ? ObserWidget(
                value: AppSnackBar.showSnackBar,
                child: (value) {
                  if (value == true) {
                    return Align(
                        alignment: widget.isDesktop
                            ? Alignment.topRight
                            : Alignment.topCenter,
                        child: SizedBox(
                            width: widget.isDesktop ? 240 : double.infinity,
                            child: AppSnackBar.snackbar));
                  }
                  return const SizedBox();
                })
            : const SizedBox(),
      ],
    );
  }
}

abstract class InitBinding {
  Future dependencies();
}
