import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:zwidget/zwidget.dart';

class AnimatedBoardWidget extends AnimatedWidget {
  final Puzzle puzzle;
  final Size contentSize;
  final Widget child;
  final Tween<double> rotationXTween;
  final Tween<double> rotationYTween;

  const AnimatedBoardWidget({
    Key? key,
    required this.puzzle,
    required this.contentSize,
    required this.child,
    required this.rotationXTween,
    required this.rotationYTween,
    required Listenable animationController,
  }) : super(key: key, listenable: animationController);

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final innerBoardSpacing = contentSize.shortestSide / 30;

    // Below values are probably animated
    // Can get Animation<double> for each
    final xTilt = rotationXTween.evaluate(_animation);
    final yTilt = rotationYTween.evaluate(_animation);

    return ZWidget(
      debug: true,
      rotationY: xTilt,
      rotationX: yTilt,
      alignment: Alignment.bottomRight,
      perspective: 1,
      depth: 0.05 * contentSize.shortestSide,
      direction: ZDirection.backwards,
      layers: 10,
      child: Container(
        child: Container(
          child: child,
          padding: EdgeInsets.all(innerBoardSpacing),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(innerBoardSpacing),
            boxShadow: [
              BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0, yTilt * 0.01 * contentSize.shortestSide))
            ],
          ),
        ),
        padding: EdgeInsets.all(innerBoardSpacing),
        decoration: BoxDecoration(
            color: HexColor("E0E0E0"),
            borderRadius: BorderRadius.circular(contentSize.shortestSide / 30)),
      ),
    );
  }
}
