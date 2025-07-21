import 'package:base/base_widget.dart';
import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/nav_2/control_nav.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:base/src/widgets/custom_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../custom_router.dart';
import '../nav_config.dart';

/// [RouterDelegate] for main flow.
final class HomeRouterDelegate extends RouterDelegate<RoutePathConfigure>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePathConfigure> {
  final InitBinding? initBinding;
  final Widget? loadingWidget;
  final bool useLoading;
  final bool useSnackbar;
  final DecorationImage? backgroundImage;
  final bool isDesktop;
  final Map<String, InitRouter> listPages;
  final String homeRouter;
  final String? splashRouter;
  final List<Widget Function()> globalWidgets;
  final List<NavigatorObserver> observers;

  HomeRouterDelegate(
      {required this.listPages,
      required this.homeRouter,
      this.splashRouter,
      this.initBinding,
      this.loadingWidget,
      this.useLoading = true,
      this.useSnackbar = true,
      this.backgroundImage,
      this.globalWidgets = const [],
      this.observers = const [],
      this.isDesktop = true,
      Function(dynamic e, String currentRouter)? onNavigationError}) {
    MainState.instance.intialize(onNavigationError: onNavigationError);
    final outerStream = MainState.instance.outerStream;
    outerStream.stream.listen(
      (value) {
        if (!listEquals(_pages, value)) {
          _pages = value.toList();
          notifyListeners();
        }
      },
    );
    final dialogStream = AppDialog.instance.dialogStream;

    dialogStream.stream.listen(
      (value) {
        if (!listEquals(_dialogs, value)) {
          _dialogs = value.toList();
          notifyListeners();
        }
      },
    );
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<Page> _pages = [];
  List<Page> _dialogs = [];

  final GlobalKey<NavigatorState> _dialogKey = GlobalKey<NavigatorState>();
  final _mainHeroCtrl = MaterialApp.createMaterialHeroController();
  final _dialogHeroCtrl = MaterialApp.createMaterialHeroController();

  @override
  Widget build(BuildContext context) {
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
        if (useSnackbar) _buildSnackbarOverlay(),
        if (useLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildMainNavigator() {
    return _pages.isNotEmpty
        ? Navigator(
            key: navigatorKey,
            pages: _pages,
            observers: observers,
            onDidRemovePage: (page){
                // Perform custom logic when a page is removed
              if (page.name != null) {
                debugPrint('Page removed: ${page.name}');
              }
              MainState.instance.pop();
              notifyListeners();
            },
          )
        : const SizedBox();
  }

  Widget _buildDialogNavigator() {
    return _dialogs.isNotEmpty
        ? Navigator(
            key: _dialogKey,
            pages: _dialogs,
            onDidRemovePage: (page){
                // Perform custom logic when a page is removed
              if (page.name != null) {
                debugPrint('Page removed: ${page.name}');
              }
              AppDialog.closeLastDialog();
              notifyListeners();
            },
          )
        : const SizedBox();
  }

  Widget _buildSnackbarOverlay() {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => ObserWidget(
            value: SnackBarController.instance.snackbars,
            child: (items) {
              if (items.isNotEmpty) {
                return Align(
                  alignment: isDesktop
                      ? Alignment.topRight
                      : Alignment.topCenter,
                  child: SizedBox(
                    width: isDesktop ? 300 : double.infinity,
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return items[index].widget;
                      },
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        )
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: ObserWidget(
        value: LoadingController.instance.showing,
        child: (value) {
          if (value == true) {
            return LoadingController.instance.loadingWidget(loadingWidget);
          }
          return const SizedBox();
        },
      ),
    );
  }

  @override
  RoutePathConfigure get currentConfiguration {
    if (_pages.length > 1) {
      return RoutePathConfigure.otherPage(
        MainState.instance.getPath(),
      );
    }
    if (MainState.instance.getCurrentRouter() == unknownPath) {
      return RoutePathConfigure.unKnown();
    }
    return RoutePathConfigure.home();
  }

  @override
  Future<void> setNewRoutePath(RoutePathConfigure configuration) async {
    if (!kIsWeb) {
      notifyListeners();
      return;
    }
    if (configuration.isUnknown) {
      MainState.instance.showUnknownRouter();
      notifyListeners();
      return;
    }
    if (configuration.lostConnected) {
      MainState.instance.showLostConnectedRouter();
      notifyListeners();
      return;
    }

    if (configuration.isHomePage) {
      MainState.instance.showHomeRouter();
      notifyListeners();
      return;
    }

    if (configuration.pathName != null) {
      MainState.instance.setOuterRoutersForWeb(
        configuration.pathName!.replaceAll('//', '/').split('/'),
      );
      notifyListeners();
      return;
    }
    notifyListeners();
  }
}
