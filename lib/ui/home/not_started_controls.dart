// import 'package:flutter/cupertino.dart';
//
// class NotStartedControls extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final space = SizedBox(height: size.height / 40);
//     return Container(
//       key: const ValueKey(2),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(size.shortestSide / 10)),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         space,
//         Row(mainAxisSize: MainAxisSize.min, children: [
//           Column(children: [
//             SvgPicture.asset(
//               AssetPath.zPuzzleIcon,
//               color: Theme.of(context).textTheme.titleLarge?.color,
//               width: size.shortestSide / 10,
//               height: size.shortestSide / 10,
//             ),
//             SizedBox(
//               height: size.shortestSide / 80,
//             )
//           ]),
//           const SizedBox(
//             width: 4,
//           ),
//           Text.rich(
//               TextSpan(children: [
//                 TextSpan(
//                     text: 'P',
//                     style: TextStyle(fontSize: size.shortestSide / 28)),
//                 TextSpan(
//                     text: 'UZZLE',
//                     style: TextStyle(fontSize: size.shortestSide / 36)),
//               ]),
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).textTheme.titleLarge?.color,
//               ))
//         ]),
//         space,
//         Text(
//           'Choose your difficulty',
//           style: TextStyle(fontSize: size.shortestSide / 34),
//         ),
//         SizedBox(height: size.height / 80),
//         SizedBox(
//           child: SizePicker(onSizePicked: (size) {
//             _puzzleSize = size;
//           }),
//           height: size.height / 12,
//         ),
//         space,
//         Text('Pick a background',
//             style: TextStyle(fontSize: size.shortestSide / 34)),
//         SizedBox(height: size.height / 80),
//         SizedBox(
//           child: Padding(
//             child: BackgroundWidgetPicker(onBackgroundPicked: (selectedWidget) {
//               setState(() {
//                 _selectedWidget = selectedWidget;
//                 print("selectedWidget not null");
//               });
//             }),
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//           ),
//           height: size.shortestSide / 8 * 3,
//           width: (size.shortestSide / 8) * 5,
//         ),
//         space,
//         ElevatedButton.icon(
//             icon: const Icon(Icons.play_arrow),
//             style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(64))),
//             onPressed: () {
//               _initPuzzle(puzzleOnly: true);
//               _settingsController!.reverse();
//             },
//             label: const Text("START")),
//         space,
//       ]),
//     );
//   }
// }
