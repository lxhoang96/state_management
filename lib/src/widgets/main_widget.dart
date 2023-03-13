import 'package:base/base_component.dart';
import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/custom_router.dart';
import 'package:base/src/nav_dialog/custom_dialog.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:base/src/widgets/custom_snackbar.dart';
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
  void didChangeDependencies() {
    BaseDialog.instance.init(context);

    super.didChangeDependencies();
  }

  @override
  void initState() {
    LoadingController.instance.showing.value = false;
    SnackBarController.instance.showSnackBar.value = false;
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
                child: ObserWidget(
                  value: LoadingController.instance.showing,
                  child: (value) {
                    if (value == true) {
                      return LoadingController.instance
                          .loadingWidget(widget.loadingWidget);
                    }
                    return const SizedBox();
                  },
                ),
              )
            : const SizedBox(),
        widget.useSnackbar
            ? ObserWidget(
                value: SnackBarController.instance.showSnackBar,
                child: (value) {
                  if (value == true) {
                    return Align(
                        alignment: widget.isDesktop
                            ? Alignment.topRight
                            : Alignment.topCenter,
                        child: SizedBox(
                            width: widget.isDesktop ? 300 : double.infinity,
                            child: SnackBarController.instance.snackbar));
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
