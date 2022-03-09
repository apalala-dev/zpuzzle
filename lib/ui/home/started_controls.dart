// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:slide_puzzle/asset-path.dart';
// import 'package:slide_puzzle/ui/timer_widget.dart';
//
// import '../../app-colors.dart';
// import '../../model/puzzle.dart';
// import '../settings/background-widget-picker.dart';
//
// class StartedControls extends StatelessWidget {
//   final Puzzle puzzle;
//   final Size size;
//   final Widget selectedWidget;
//   final bool showIndicator;
//   final bool solving;
//   final VoidCallback giveUp;
//   final VoidCallback solve;
//   final VoidCallback showIndicatorChanged;
//   final Function(Widget) onWidgetPicked;
//   final GlobalKey timerKey;
//
//   const StartedControls({
//     Key? key,
//     required this.puzzle,
//     required this.size,
//     required this.selectedWidget,
//     required this.showIndicator,
//     required this.solving,
//     required this.showIndicatorChanged,
//     required this.onWidgetPicked,
//     required this.timerKey,
//     required this.giveUp,
//     required this.solve,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final title = Row(mainAxisSize: MainAxisSize.min, children: [
//       Column(children: [
//         SvgPicture.asset(
//           AssetPath.zPuzzleIcon,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//           width: screenSize.shortestSide / 15,
//           height: screenSize.shortestSide / 15,
//         ),
//         SizedBox(
//           height: screenSize.shortestSide / 80,
//         )
//       ]),
//       const SizedBox(
//         width: 4,
//       ),
//       Text.rich(
//           TextSpan(children: [
//             TextSpan(
//                 text: 'P',
//                 style: TextStyle(fontSize: screenSize.shortestSide / 40)),
//             TextSpan(
//                 text: 'UZZLE',
//                 style: TextStyle(fontSize: screenSize.shortestSide / 52)),
//           ]),
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).textTheme.titleLarge?.color,
//           ))
//     ]);
//     final counter = Text.rich(TextSpan(
//         children: [
//           TextSpan(
//               text: "${puzzle.history.length}",
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//           const TextSpan(text: " Moves"),
//         ],
//         style: TextStyle(
//             fontSize: screenSize.shortestSide / 34,
//             color: Theme.of(context).textTheme.titleLarge?.color)));
//
//     final timer = TimerWidget(
//       key: timerKey,
//     );
//
//     final toggle = Row(mainAxisSize: MainAxisSize.min, children: [
//       Switch(
//         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         // activeColor: Theme.of(context).primaryColor,
//         // activeColor: HexColor('FF985E'),
//         value: showIndicator,
//         onChanged: (value) {
//           setState(() {
//             showIndicator = !showIndicator;
//           });
//         },
//       ),
//       InkWell(
//         child: const Text('Show help'),
//         onTap: () => setState(() {
//           showIndicator = !showIndicator;
//         }),
//       ),
//     ]);
//
//     final separator = Padding(
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 1,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Theme.of(context)
//                     .textTheme
//                     .titleLarge
//                     ?.color
//                     ?.withOpacity(0.26),
//               ),
//             ),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 4),
//     );
//     final giveUpButton = TextButton.icon(
//       style: TextButton.styleFrom(primary: Colors.red),
//       onPressed: () {
//         showGeneralDialog(
//           context: context,
//           pageBuilder: (BuildContext ctx, Animation<double> animation,
//               Animation<double> secondaryAnimation) {
//             return AlertDialog(
//               title: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [const Text('Give up?')]),
//               actionsAlignment: MainAxisAlignment.center,
//               actions: [
//                 TextButton(
//                   child: const Text('No'),
//                   onPressed: () {
//                     Navigator.pop(ctx);
//                   },
//                 ),
//                 TextButton(
//                   child: const Text('Yes'),
//                   onPressed: () {
//                     Navigator.pop(ctx);
//                     giveUp();
//                   },
//                 ),
//               ],
//             );
//           },
//           transitionBuilder: (ctx, a1, a2, child) {
//             return Transform.scale(
//                 child: child, scale: Curves.easeOutBack.transform(a1.value));
//           },
//         );
//       },
//       icon: const Icon(Icons.flag, size: 20),
//       label: const Text('GIVE UP'),
//     );
//     final selectedChildWidget = ClipRRect(
//       child: selectedWidget ?? const SizedBox(),
//       borderRadius: BorderRadius.circular(8),
//     );
//     final RenderObjectWidget selectedWidget;
//     if (size.height == size.shortestSide) {
//       selectedWidget =
//           Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//         const SizedBox(width: 40),
//         AspectRatio(
//           child: Container(
//             child: selectedChildWidget,
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 2)
//                 ]),
//           ),
//           aspectRatio: 1,
//         ),
//         FloatingActionButton.small(
//           // backgroundColor: Theme.of(context).primaryColor,
//           onPressed: _showWidgetPickerDialog,
//           child: const Icon(Icons.edit),
//         ),
//       ]);
//     } else {
//       selectedWidget = AspectRatio(
//         child: Container(
//           child: Stack(children: [
//             Positioned.fill(child: selectedChildWidget),
//             Align(
//               child: Padding(
//                 child: FloatingActionButton.small(
//                   onPressed: _showWidgetPickerDialog,
//                   child: const Icon(Icons.edit),
//                 ),
//                 padding: const EdgeInsets.only(bottom: 4, right: 4),
//               ),
//               alignment: Alignment.bottomRight,
//             )
//           ]),
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: const [
//                 BoxShadow(color: Colors.black26, blurRadius: 2)
//               ]),
//         ),
//         aspectRatio: 1,
//       );
//     }
//
//     final solveButton = AnimatedSwitcher(
//       duration: const Duration(milliseconds: 500),
//       transitionBuilder: (child, anim) {
//         return ScaleTransition(
//           child: child,
//           scale: anim,
//         );
//       },
//       child: solving
//           ? OutlinedButton.icon(
//               style: OutlinedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(32)),
//                   primary: Theme.of(context).brightness == Brightness.light
//                       ? Colors.black87
//                       : Colors.white,
//                   side: BorderSide(
//                       width: 2,
//                       color: Theme.of(context).brightness == Brightness.light
//                           ? Colors.black87
//                           : Colors.white)),
//               onPressed: () {
//                 setState(() {
//                   solving = false;
//                 });
//               },
//               icon: const Icon(Icons.stop),
//               label: const Text("CANCEL"),
//             )
//           : puzzle.isComplete()
//               ? const SizedBox(height: 28)
//               : ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(32))),
//                   onPressed: () {
//                     solve();
//                   },
//                   icon: const Icon(Icons.extension, size: 20),
//                   label: const Text("SOLVE"),
//                 ),
//     );
//
//     if (size.height == size.shortestSide) {
//       return Padding(
//         padding: EdgeInsets.only(right: size.width / 50),
//         child: Container(
//           key: const ValueKey(1),
//           padding: EdgeInsets.symmetric(
//               horizontal: size.shortestSide / 40,
//               vertical: size.shortestSide / 100),
//           height: min(max(size.shortestSide / 2, 220), 350),
//           decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? AppColors.boardOuterColor(context)
//                   : AppColors.boardInnerColor(context),
//               borderRadius: BorderRadius.circular(size.shortestSide / 40)),
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 title,
//                 SizedBox(
//                   child: selectedWidget,
//                   height: size.shortestSide / 8,
//                 ),
//                 Column(children: [
//                   toggle,
//                   solveButton,
//                 ]),
//                 Row(children: [
//                   Expanded(
//                       child: Align(
//                     child: counter,
//                     alignment: Alignment.centerRight,
//                   )),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   Expanded(child: timer),
//                 ]),
//                 separator,
//                 giveUpButton,
//               ]),
//         ),
//       );
//     } else {
//       return Container(
//         key: const ValueKey(1),
//         padding: EdgeInsets.symmetric(
//             horizontal: size.shortestSide / 40,
//             vertical: size.shortestSide / 100),
//         height: max(size.shortestSide / 3.2, 200),
//         width: max(size.shortestSide / 1.5, 260),
//         decoration: BoxDecoration(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? AppColors.boardOuterColor(context)
//                 : AppColors.boardInnerColor(context),
//             borderRadius: BorderRadius.circular(size.shortestSide / 40)),
//         child:
//             Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//           SizedBox(
//             height: max(size.shortestSide / 6, 130),
//             child: Row(children: [
//               Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       title,
//                       toggle,
//                       solveButton,
//                     ],
//                   ),
//                   flex: 6),
//               Expanded(child: selectedWidget, flex: 5),
//             ]),
//           ),
//           separator,
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             giveUpButton,
//             counter,
//             timer,
//           ]),
//         ]),
//       );
//     }
//   }
//
//   void _showWidgetPickerDialog() {
//     showGeneralDialog(
//       context: context,
//       pageBuilder: (BuildContext ctx, Animation<double> animation,
//           Animation<double> secondaryAnimation) {
//         return AlertDialog(
//           title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Text('Pick a new background'),
//           ]),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height / 3,
//               width: MediaQuery.of(context).size.width / 2,
//               child: BackgroundWidgetPicker(
//                   currentlySelectedWidget: selectedWidget,
//                   onBackgroundPicked: (selectedWidget) {
//                     // setState(() {
//                     //   _selectedWidget = selectedWidget;
//                     // });
//                     Navigator.pop(context, selectedWidget);
//                   }),
//             ),
//             TextButton(
//               child: Text('CANCEL'),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             )
//           ]),
//         );
//       },
//       transitionBuilder: (ctx, a1, a2, child) {
//         return Transform.scale(
//             child: child, scale: Curves.easeOutBack.transform(a1.value));
//       },
//     ).then((newWidget) {
//       if (newWidget != null && newWidget is Widget) {
//         setState(() {
//           _selectedWidget = newWidget;
//         });
//       }
//     });
//   }
// }
