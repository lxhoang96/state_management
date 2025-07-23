import 'package:base/base_widget.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../base_component.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/main_widget.dart';
import '../custom_router.dart';
import '../nav_config.dart';

/// [RouterDelegate] for main flow - focused only on navigation
final class HomeRouterDelegate extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  final InitBinding? initBinding;
  final DecorationImage? backgroundImage;
  final Map<String, InitRouter> listPages;
  final String homeRouter;
  final String? splashRouter;
  final List<Widget Function()> globalWidgets;
  final List<NavigatorObserver> observers;

  HomeRouterDelegate({
    required this.listPages,
    required this.homeRouter,
    this.splashRouter,
    this.initBinding,
    this.backgroundImage,
    this.globalWidgets = const [],
    this.observers = const [],
    Function(dynamic e, String currentRouter)? onNavigationError,
  }) {
    MainState.instance.intialize(onNavigationError: onNavigationError);
    _setupStreamListeners();
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<Page> _pages = [];
  List<Page> _dialogs = [];

  final GlobalKey<NavigatorState> _dialogKey = GlobalKey<NavigatorState>();
  final _mainHeroCtrl = MaterialApp.createMaterialHeroController();
  final _dialogHeroCtrl = MaterialApp.createMaterialHeroController();

  void _setupStreamListeners() {
    MainState.instance.outerStream.stream.listen((value) {
      if (!listEquals(_pages, value)) {
        _pages = value.toList();
        notifyListeners();
      }
    });

    AppDialog.instance.dialogStream.stream.listen((value) {
      if (!listEquals(_dialogs, value)) {
        _dialogs = value.toList();
        notifyListeners();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Only navigation logic - no overlays!
    return Stack(
      children: [
        GlobalWidget(
          listPages: listPages,
          homeRouter: homeRouter,
          splashRouter: splashRouter,
          initBinding: initBinding,
          backgroundImage: backgroundImage,
          globalWidgets: globalWidgets,
          child: HeroControllerScope(
            controller: _mainHeroCtrl,
            child: _buildMainNavigator(),
          ),
        ),
        HeroControllerScope(
          controller: _dialogHeroCtrl,
          child: _buildDialogNavigator(),
        ),
      ],
    );
  }

  Widget _buildMainNavigator() {
    return _pages.isNotEmpty
        ? Navigator(
            key: navigatorKey,
            pages: _pages,
            observers: observers,
            onDidRemovePage: (page) {
              if (page.name != null) {
                debugPrint('Page removed: ${page.name}');
              }
            },
          )
        : const SizedBox();
  }

  Widget _buildDialogNavigator() {
    return _dialogs.isNotEmpty
        ? Navigator(
            key: _dialogKey,
            pages: _dialogs,
            onDidRemovePage: (dialog) {
              if (dialog.name != null) {
                debugPrint('Dialog removed: ${dialog.name}');
              }
              AppDialog.closeLastDialog();
            },
          )
        : const SizedBox();
  }

  @override
  RoutePathConfigure get currentConfiguration {
    if (_pages.length > 1) {
      return RoutePathConfigure.otherPage(MainState.instance.getPath());
    }
    if (MainState.instance.getCurrentRouter() == unknownPath) {
      return RoutePathConfigure.unKnown();
    }
    return RoutePathConfigure.home();
  }

  @override
  Future<void> setNewRoutePath(RoutePathConfigure configuration) async {
    if (!kIsWeb) return;

    if (configuration.isUnknown) {
      MainState.instance.showUnknownRouter();
      return;
    }
    if (configuration.lostConnected) {
      MainState.instance.showLostConnectedRouter();
      return;
    }
    if (configuration.isHomePage) {
      MainState.instance.showHomeRouter();
      return;
    }
    if (configuration.pathName != null) {
      MainState.instance.setOuterRoutersForWeb(
        configuration.pathName!.replaceAll('//', '/').split('/'),
      );
    }
  }
}


/// Private builder function for app overlays
Widget _buildAppWithOverlays(
  BuildContext context,
  Widget? child, {
  bool useSnackbar = true,
  bool useLoading = true,
  bool isDesktop = false,
  Widget? customLoadingWidget,
}) {
  return Stack(
    children: [
      // ✅ Main app content
      child ?? const SizedBox.shrink(),
      
      // ✅ Global overlays
      if (useSnackbar) 
        _GlobalSnackbarOverlay(isDesktop: isDesktop),
      if (useLoading)
        _GlobalLoadingOverlay(loadingWidget: customLoadingWidget),
    ],
  );
}

/// Global snackbar overlay
class _GlobalSnackbarOverlay extends StatelessWidget {
  final bool isDesktop;
  
  const _GlobalSnackbarOverlay({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: isDesktop ? null : 10,
      right: 10,
      child: RepaintBoundary(
        key: const ValueKey('global_snackbar'),
        child: ObserWidget(
          value: SnackBarController.instance.snackbars,
          child: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            
            return SizedBox(
              width: isDesktop ? 300 : null,
              child: Column(
                crossAxisAlignment: isDesktop 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.center,
                children: items
                    .take(5) // ✅ Limit to 5 snackbars max
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: item.widget,
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Global loading overlay
class _GlobalLoadingOverlay extends StatelessWidget {
  final Widget? loadingWidget;
  
  const _GlobalLoadingOverlay({this.loadingWidget});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        key: const ValueKey('global_loading'),
        child: ObserWidget(
          value: LoadingController.instance.showing,
          child: (isShowing) {
            if (!isShowing) return const SizedBox.shrink();
            
            return Container(
              color: Colors.black54,
              child: LoadingController.instance.loadingWidget(loadingWidget),
            );
          },
        ),
      ),
    );
  }
}

/// Public factory class for app builders
final class AppBuilderFactory {
  AppBuilderFactory._();
  
  /// Create a builder function for MaterialApp.router
  static Widget Function(BuildContext, Widget?) createMaterialAppBuilder({
    bool useSnackbar = true,
    bool useLoading = true,
    bool isDesktop = false,
    Widget? customLoadingWidget,
  }) {
    return (context, child) => _buildAppWithOverlays(
      context,
      child,
      useSnackbar: useSnackbar,
      useLoading: useLoading,
      isDesktop: isDesktop,
      customLoadingWidget: customLoadingWidget,
    );
  }
  
  /// Create a builder function for CupertinoApp.router
  static Widget Function(BuildContext, Widget?) createCupertinoAppBuilder({
    bool useSnackbar = true,
    bool useLoading = true,
    bool isDesktop = false,
    Widget? customLoadingWidget,
  }) {
    return (context, child) => _buildAppWithOverlays(
      context,
      child,
      useSnackbar: useSnackbar,
      useLoading: useLoading,
      isDesktop: isDesktop,
      customLoadingWidget: customLoadingWidget,
    );
  }
}