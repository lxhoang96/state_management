import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/custom_router.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

class GlobalWidget extends StatefulWidget {
  const GlobalWidget(
      {Key? key,
      required this.child,
      this.initBinding,
      this.loadingWidget,
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
  final Map<String, InitRouter> listPages;
  final Widget? loadingWidget;
  final bool useLoading;
  final bool useSnackbar;

  final bool isDesktop;
  final DecorationImage? backgroundImage;
  final String homeRouter;
  final List<Widget> globalWidgets;
  @override
  State<GlobalWidget> createState() => _GlobalWidgetState();
}

class _GlobalWidgetState extends State<GlobalWidget> {
  bool didInit = false;
  @override
  void initState() {
    LoadingController.instance.showing.value = false;
    AppSnackBar.showSnackBar.value = false;
    MainState.instance.setInitRouters(widget.listPages);
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  init() async {
    await widget.initBinding?.dependencies();
    MainState.instance.setHomeRouter(widget.homeRouter);
    didInit = true;
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
        buildChild(),
        widget.useLoading
            ? Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: LoadingController.instance.showing,
                  builder: (context,value,_) {
                    if (value == true) {
                      return LoadingController.instance.loadingWidget(widget.loadingWidget);
                    }
                    return const SizedBox();
                  },
                ),
              )
            : const SizedBox(),
        widget.useSnackbar
            ? ValueListenableBuilder(
                valueListenable: AppSnackBar.showSnackBar,
                builder: (context,value,_) {
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
        ...widget.globalWidgets,
      ],
    );
  }
}

abstract class InitBinding {
  Future dependencies();
}
