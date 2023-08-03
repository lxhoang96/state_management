import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/custom_router.dart';
import 'package:base/src/nav_dialog/custom_dialog.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:base/src/theme/sizes.dart';
import 'package:base/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class GlobalWidget extends StatefulWidget {
  const GlobalWidget(
      {Key? key,
      required this.child,
      this.splashRouter,
      this.initBinding,
      this.backgroundImage,
      this.globalWidgets = const [],
      required this.listPages,
      required this.homeRouter})
      : super(key: key);
  final Widget child;
  final String? splashRouter;
  final InitBinding? initBinding;
  final Map<String, InitRouter> listPages;

  final DecorationImage? backgroundImage;
  final String homeRouter;
  final List<Widget Function()> globalWidgets;

  @override
  State<GlobalWidget> createState() => _GlobalWidgetState();
}

class _GlobalWidgetState extends State<GlobalWidget> {
  bool _didInit = false;
  final List<Widget> _globalWidget = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    LoadingController.instance.showing.value = false;
    SnackBarController.instance.showSnackBar.value = false;
    MainState.instance.setInitRouters(widget.listPages);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init();
      BaseDialog.instance.init(context);
      BaseSizes.instance.init(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  init() async {
    if (widget.splashRouter != null) {
      MainState.instance.goSplashScreen(widget.splashRouter!);
    }
    await widget.initBinding?.dependencies();
    for (final each in widget.globalWidgets) {
      _globalWidget.add(each.call());
    }
    _didInit = true;
    MainState.instance.setHomeRouter(widget.homeRouter);
  }

  // Widget buildChild() {
  //   if (_didInit) {
  //     return Material(
  //       color: Colors.transparent,
  //       child: Container(
  //           decoration: BoxDecoration(image: widget.backgroundImage),
  //           child: widget.child),
  //     );
  //   }
  //   return const SizedBox();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(image: widget.backgroundImage),
            child: widget.child),
      ),
        if (_didInit)  ..._globalWidget,
      ],
    );
  }
}

abstract class InitBinding {
  Future dependencies();
}
