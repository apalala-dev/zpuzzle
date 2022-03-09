// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// import 'package:slide_puzzle/app-colors.dart';
// import 'package:slide_puzzle/ui/home/started_controls.dart';
// import 'package:zwidget/zwidget.dart';
//
// class GameProgress extends AnimatedWidget {
//   final Size size;
//   final VoidCallback giveUp;
//   final VoidCallback solve;
//   final bool solving;
//
//   const GameProgress({
//     Key? key,
//     required Listenable listenable,
//     required this.size,
//     required this.giveUp,
//     required this.solving,
//     required this.solve,
//   }) : super(key: key, listenable: listenable);
//
//   Animation<double> get _animation => listenable as Animation<double>;
//
//   @override
//   Widget build(BuildContext context) {
//     final xTilt = Tween<double>(begin: -2 * pi, end: 0.0)
//         .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
//         .evaluate(_animation);
//     final yTilt = Tween<double>(begin: -2 * pi, end: 0.0)
//         .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
//         .evaluate(_animation);
//     final scale = Tween<double>(begin: 0.0, end: 1.0)
//         .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
//         .evaluate(_animation);
//
//     return Transform.scale(
//       child: ZWidget(
//         midChild: RepaintBoundary(
//             child: size.shortestSide == size.height
//                 ? Padding(
//                     padding: EdgeInsets.only(right: size.width / 50),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: size.shortestSide / 40,
//                           vertical: size.shortestSide / 100),
//                       height: min(max(size.shortestSide / 2, 220), 350),
//                       decoration: BoxDecoration(
//                           color: AppColors.perspectiveColor,
//                           borderRadius:
//                               BorderRadius.circular(size.shortestSide / 30)),
//                     ))
//                 : Container(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: size.shortestSide / 40,
//                         vertical: size.shortestSide / 100),
//                     height: max(size.shortestSide / 3.2, 200),
//                     width: max(size.shortestSide / 1.5, 260),
//                     decoration: BoxDecoration(
//                         color: AppColors.perspectiveColor,
//                         borderRadius:
//                             BorderRadius.circular(size.shortestSide / 30)),
//                   )),
//         topChild: RepaintBoundary(
//           child: StartedControls(
//             size: size,
//             puzzle: puzzle,
//             onWidgetPicked: (w) {},
//             showIndicator: showIndicator,
//             selectedWidget: selectedWidget,
//             showIndicatorChanged: () {},
//             solving: solving,
//             timerKey: timerKey,
//             giveUp: giveUp,
//           ),
//         ),
//         rotationX: xTilt,
//         rotationY: yTilt,
//         //_doorsFlip.value,
//         depth: 10,
//         direction: ZDirection.forwards,
//         layers: 5,
//         alignment: Alignment.center,
//       ),
//       scale: scale,
//     );
//   }
// }
