import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/board-content.dart';
import 'package:zwidget/zwidget.dart';

import '../app-colors.dart';

class AnimatedBoardWidget extends AnimatedWidget {
  final Puzzle puzzle;
  final Size contentSize;
  final Size boardContentSize;
  final Widget botChild;
  final Widget? topChild;
  final Widget selectedTileWidget;
  final Function(Tile) onTileMoved;
  final Tween<double> rotationXTween;
  final Tween<double> rotationYTween;
  final Tween<double> scaleTween;
  final Offset gyroEvent;
  final bool showIndicator;

  const AnimatedBoardWidget({
    Key? key,
    required this.puzzle,
    required this.contentSize,
    required this.botChild,
    this.topChild,
    required this.selectedTileWidget,
    required this.onTileMoved,
    required this.rotationXTween,
    required this.rotationYTween,
    required this.scaleTween,
    required Listenable animationController,
    required this.boardContentSize,
    this.gyroEvent = Offset.zero,
    this.showIndicator = true,
  }) : super(key: key, listenable: animationController);

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final innerBoardSpacing = contentSize.shortestSide / 30;

    var xTilt = rotationXTween
            // .chain(CurveTween(curve: Curves.elasticInOut))
            // .chain(CurveTween(curve: Curves.easeOut))
            // .chain(CurveTween(curve: Curves.easeInOut))
            .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
            .evaluate(_animation) +
        (gyroEvent.dx * 2 * pi);
    var yTilt = rotationYTween
            // .chain(CurveTween(curve: Curves.elasticInOut))
            // .chain(CurveTween(curve: Curves.easeIn))
            .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
            .evaluate(_animation) +
        (gyroEvent.dy * 2 * pi);
    final scale = scaleTween
        // .chain(CurveTween(curve: Curves.elasticInOut))
        .chain(CurveTween(curve: Curves.linearToEaseOut))
        .evaluate(_animation);

    // return Transform.scale(
    //   child: BoardContent(
    //       contentSize: contentSize,
    //       puzzle: puzzle,
    //       backgroundWidget: selectedTileWidget,
    //       onTileMoved: onTileMoved,
    //       xTilt: 0,
    //       yTilt: 0),
    //   scale: scale,
    // );

    // xTilt = pi/9;
    // yTilt = -pi/9;

    return Transform.scale(
      scale: scale,
      child: ZWidget(
        debug: false,
        rotationY: xTilt,
        // xTilt,
        rotationX: yTilt,
        alignment: Alignment.center,
        perspective: 0.5,
        depth: 30,
        direction: ZDirection.forwards,
        layers: 11,
        midChild: botChild,
        topChild: topChild ??
            Container(
              child: Container(
                child: false
                    ? ZWidget(
                        midChild: Container(
                          width: boardContentSize.width,
                          height: boardContentSize.width,
                          color: Colors.pink,
                        ),
                        topChild: Container(
                          width: boardContentSize.width,
                          height: boardContentSize.width,
                          color: Colors.red,
                        ),
                        depth: 20,
                        layers: 5,
                        direction: ZDirection.forwards,
                      )
                    : BoardContent(
                        puzzle: puzzle,
                        contentSize: boardContentSize,
                        backgroundWidget: selectedTileWidget,
                        onTileMoved: onTileMoved,
                        xTilt: 0,
                        yTilt: 0,
                        showIndicator: showIndicator,
                      ),
                padding: EdgeInsets.all(innerBoardSpacing),
                decoration: BoxDecoration(
                  color: AppColors.boardInnerColor(context), //Colors.white,
                  borderRadius: BorderRadius.circular(innerBoardSpacing),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(
                            xTilt < 0
                                ? max(xTilt * 0.05 * contentSize.shortestSide,
                                    -innerBoardSpacing / 4)
                                : min(xTilt * 0.05 * contentSize.shortestSide,
                                    innerBoardSpacing / 4),
                            yTilt < 0
                                ? max(yTilt * 0.05 * contentSize.shortestSide,
                                    -innerBoardSpacing / 4)
                                : min(yTilt * 0.05 * contentSize.shortestSide,
                                    innerBoardSpacing / 4)))
                  ],
                ),
              ),
              padding: EdgeInsets.all(innerBoardSpacing),
              decoration: BoxDecoration(
                  color: AppColors.boardOuterColor(context),
                  //HexColor("E0E0E0").withOpacity(0.5),
                  borderRadius:
                      BorderRadius.circular(contentSize.shortestSide / 30)),
            ),
      ),
    );
  }
}
