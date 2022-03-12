import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zpuzzle/asset_path.dart';

class ZPuzzleTitle extends StatelessWidget {
  final double sizeMultiplier;
  final double? maxSize;

  const ZPuzzleTitle({Key? key, this.sizeMultiplier = 1.0, this.maxSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize =
        min(screenSize.shortestSide / 15 * sizeMultiplier, maxSize ?? 48);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Column(children: [
        SvgPicture.asset(
          AssetPath.zPuzzleIcon,
          color: Theme.of(context).textTheme.titleLarge?.color,
          width: iconSize,
          height: iconSize,
        ),
        SizedBox(
          height: iconSize * 0.2,
        )
      ]),
      const SizedBox(
        width: 4,
      ),
      Text.rich(
          TextSpan(children: [
            TextSpan(text: 'P', style: TextStyle(fontSize: iconSize * 0.42)),
            TextSpan(text: 'UZZLE', style: TextStyle(fontSize: iconSize * 0.3)),
          ]),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ))
    ]);
  }
}
