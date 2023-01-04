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
      this.backgroundImage,
      this.globalWidgets = const [],
      required this.listPages,
      required this.homeRouter})
      : super(key: key);
  final Widget child;
  final InitBinding? initBinding;
  final Widget Function()? Function(String name) listPages;
  final String? appIcon;
  final bool useLoading;
  final bool useSnackbar;
  final bool isDesktop;
  final DecorationImage? backgroundImage;
  final String homeRouter;
  final List<Widget> globalWidgets;
  @override
  State<GlobalState> createState() => _GlobalStateState();
}

class _GlobalStateState extends State<GlobalState> {
  bool didInit = false;
  @override
  void initState() {
    AppLoading.showing.value = false;
    AppSnackBar.showSnackBar.value = false;
    Global.setInitPages(widget.listPages);
    if (widget.initBinding == null) {
      setState(() {
        didInit = true;
      });
    } else {
      widget.initBinding?.dependencies().then((value) => setState(() {
            Global.setHomeRouter(widget.homeRouter);
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
      return Material(
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(image: widget.backgroundImage),
            child: widget.child),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.globalWidgets,
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
