import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/app_colors.dart';
import 'package:slide_puzzle/ui/home/started_controls.dart';
import 'package:slide_puzzle/ui/zwidget_wrapper.dart';
import 'package:zwidget/zwidget.dart';

import '../../model/puzzle.dart';

class GameProgress extends AnimatedWidget {
  final Puzzle puzzle;
  final Size size;
  final Widget? selectedWidget;
  final bool solving;
  final bool showIndicator;
  final VoidCallback giveUp;
  final VoidCallback solve;
  final VoidCallback showIndicatorChanged;
  final VoidCallback stoppedSolving;
  final Function(Widget) onWidgetPicked;
  final GlobalKey timerKey;
  final bool gyroEnabled;
  final VoidCallback gyroChanged;

  const GameProgress({
    Key? key,
    required Listenable listenable,
    required this.puzzle,
    required this.size,
    required this.selectedWidget,
    required this.solving,
    required this.showIndicator,
    required this.giveUp,
    required this.solve,
    required this.showIndicatorChanged,
    required this.stoppedSolving,
    required this.onWidgetPicked,
    required this.timerKey,
    required this.gyroEnabled,
    required this.gyroChanged,
  }) : super(key: key, listenable: listenable);

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final xTilt = Tween<double>(begin: -2 * pi, end: 0.0)
        .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
        .evaluate(_animation);
    final yTilt = Tween<double>(begin: -2 * pi, end: 0.0)
        .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
        .evaluate(_animation);
    final scale = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
        .evaluate(_animation);

    return Transform.scale(
      child: ZWidgetWrapper(
        midChild: RepaintBoundary(
            child: size.shortestSide == size.height
                ? Padding(
                    padding: EdgeInsets.only(right: size.width / 50),
                    child: DecoratedBox(
                      child: kIsWeb
                          ? Container()
                          : Opacity(
                              child: StartedControls(
                                isBuildForPerspective: true,
                                size: size,
                                puzzle: puzzle,
                                onWidgetPicked: onWidgetPicked,
                                showIndicator: showIndicator,
                                selectedWidget: selectedWidget,
                                showIndicatorChanged: showIndicatorChanged,
                                solving: solving,
                                stoppedSolving: stoppedSolving,
                                timerKey: null,
                                solve: solve,
                                giveUp: giveUp,
                                gyroEnabled: gyroEnabled,
                                gyroChanged: gyroChanged,
                              ),
                              opacity: 0,
                            ),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(size.shortestSide / 40),
                          color: AppColors.perspectiveColor),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.shortestSide / 40,
                        vertical: size.shortestSide / 100),
                    height: max(size.height / 3.2, 180),
                    width: max(size.shortestSide * 0.8, 260),
                    decoration: BoxDecoration(
                        color: AppColors.perspectiveColor,
                        borderRadius:
                            BorderRadius.circular(size.shortestSide / 30)),
                  )),
        topChild: RepaintBoundary(
          child: StartedControls(
            size: size,
            puzzle: puzzle,
            onWidgetPicked: onWidgetPicked,
            showIndicator: showIndicator,
            selectedWidget: selectedWidget,
            showIndicatorChanged: showIndicatorChanged,
            solving: solving,
            timerKey: timerKey,
            stoppedSolving: stoppedSolving,
            solve: solve,
            giveUp: giveUp,
            gyroEnabled: gyroEnabled,
            gyroChanged: gyroChanged,
          ),
        ),
        rotationX: xTilt,
        rotationY: yTilt,
        depth: 20,
        direction: ZDirection.forwards,
        layers: 5,
        alignment: Alignment.center,
      ),
      scale: scale,
    );
  }
}
