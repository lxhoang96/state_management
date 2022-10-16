import 'package:base/src/base_component/base_observer.dart';
import 'package:base/src/base_httpclient/custom_client.dart';
import 'package:flutter/material.dart';

// class AppDialog {
//   static late Route route;
//   static closeLoading() {
//     AppRouter.removeRoute(route);
//     debugPrint("Dialog Off Screen");
//   }

//   static loading() {
//     // if (Get.isOverlaysOpen) {
//     //   Get.back();
//     // }
//     // if(route.po)
//     route = DialogRoute(
//         context: AppRouter.navigatorKey.currentContext!,
//         settings: const RouteSettings(),
//         builder: (context) => Center(
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   const SizedBox(
//                       width: 65,
//                       height: 65,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                       )),
//                   SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: Image.asset(AppImages.landingImg('icon_robot')),
//                   )
//                 ],
//               ),
//             ));
//     AppRouter.pushRoute(route);
//     debugPrint("Dialog On Screen");
//     // showGeneralDialog(
//     //   context: AppRouter.navigatorKey.currentContext!,
//     //   barrierColor: Colors.black38,
//     //   pageBuilder: (context, animation, secondaryAnimation) {
//     //     return Center(
//     //       child: Stack(
//     //         alignment: Alignment.center,
//     //         children: [
//     //           SizedBox(
//     //               width: 65,
//     //               height: 65,
//     //               child: CircularProgressIndicator(
//     //                 color: Colors.white,
//     //               )),
//     //           SizedBox(
//     //             width: 50,
//     //             height: 50,
//     //             child: Image.asset(AppImages.landingImg('icon_robot')),
//     //           )
//     //         ],
//     //       ),
//     //     );
//     //   },
//     //   transitionBuilder: (context, anim1, anim2, child) {
//     //     return FadeTransition(
//     //       opacity: anim1,
//     //       child: child,
//     //     );
//     //   },
//     // );
//     Future.delayed(const Duration(seconds: REQUEST_TIME_OUT)).then((value) {
//       closeLoading();
//     });
//   }
// }

class AppDialog {
  static final showing = Observer<bool>(initValue: false);
  static Widget showDialog(String image) {
    Future.delayed(const Duration(seconds: REQUEST_TIME_OUT)).then((value) {
      closeLoading();
    });
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  color: Colors.white,
                )),
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(image), //AppImages.landingImg('icon_robot')
            )
          ],
        ),
      ),
    );
  }

  static closeLoading() {
    showing.value = false;
    debugPrint("Dialog Off Screen");
  }
}
