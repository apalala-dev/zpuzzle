import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class MovingStar {
  Offset basePosition;
  Offset dest;
  int timeToFinish; // in ms
  int timeAltreadySpent;
  double startingSize;
  double endingSize;
  Color color;
  int distance;

  MovingStar(
      {required this.basePosition,
      required this.dest,
      required this.startingSize,
      required this.color,
      required this.timeToFinish,
      this.timeAltreadySpent = 0,
      required this.distance,
      double? endingSize})
      : endingSize = endingSize ?? startingSize;

  /// based on https://math.stackexchange.com/a/1630886
  Offset calculatedPosition(int timeSpent,
      {Offset? center, Offset? mousePosition}) {
    var t = ((timeSpent - timeAltreadySpent) / timeToFinish);
    var newX = ((1 - t) * basePosition.dx + t * dest.dx);
    var newY = ((1 - t) * basePosition.dy + t * dest.dy);
    if (mousePosition == null || center == null) {
      return Offset(newX, newY);
    } else {
      return Offset(
          newX +
              (center.dx / distance) *
                  (center.dx - mousePosition.dx) /
                  center.dx,
          newY +
              (center.dy / distance) *
                  (center.dy - mousePosition.dy) /
                  center.dy);
    }
  }

  bool willIntersect(Rect canvasRect, int currentTimer) {
    Offset currentPos = calculatedPosition(currentTimer);
    Offset laterPos =
        calculatedPosition(currentTimer + 5.seconds.inMilliseconds);
    Path p = Path();
    p.moveTo(currentPos.dx, currentPos.dy);
    p.lineTo(laterPos.dx, laterPos.dy);
    // p.lineTo(laterPos.dx + 0.5, laterPos.dy + 0.5);
    // p.lineTo(currentPos.dx + 0.5, currentPos.dy + 0.5);
    p.close();
    var intersect =
        Path.combine(PathOperation.intersect, p, Path()..addRect(canvasRect));
    // print("bounds intersect: ${intersect.getBounds()} - ${intersect.getBounds().size} - ${intersect.getBounds().size.isEmpty}");
    return !intersect.getBounds().size.isEmpty;
  }

  static Offset offsetOutside(Rect canvasRect, int distance,
      {double? xBase, double? yBase, bool allowInside = false}) {
    bool xBaseOutsideNeg = xBase != null && xBase < 0;
    bool xBaseOutsidePos = xBase != null && xBase > canvasRect.width;
    bool yBaseOutsideNeg = yBase != null && yBase < 0;
    bool yBaseOutsidePos = yBase != null && yBase > canvasRect.height;

    Random rand = Random();
    double newX;
    do {
      newX = rand.nextDouble() * (canvasRect.width + 2 * distance) - distance;
    } while (xBaseOutsideNeg && newX < 0 ||
        xBaseOutsidePos && newX > canvasRect.width);

    double newY;
    if (canvasRect.contains(Offset(newX, canvasRect.center.dy))) {
      // Only allow y outside of the canvasRect
      do {
        newY =
            rand.nextDouble() * (canvasRect.height + 2 * distance) - distance;
      } while (yBaseOutsideNeg && newY < 0 ||
          yBaseOutsidePos && newY > canvasRect.height ||
          (!allowInside && canvasRect.contains(Offset(newX, newY))));
    } else {
      do {
        newY =
            rand.nextDouble() * (canvasRect.height + 2 * distance) - distance;
      } while (yBaseOutsideNeg && newY < 0 ||
          yBaseOutsidePos && newY > canvasRect.height);
    }
    return Offset(newX, newY);
  }

  static Offset offsetInCenter(
    Rect canvasRect,
    double distance,
  ) {
    var rand = Random();
    return Offset(
        canvasRect.center.dx - distance / 2 + rand.nextDouble() * distance,
        canvasRect.center.dy - distance / 2 + rand.nextDouble() * distance);
  }

  void recreateElsewhere(
      Rect canvasRect, int distance, int alreadySpent, int newTimeToFinish) {
    basePosition = MovingStar.offsetOutside(canvasRect, 200);
    timeAltreadySpent = alreadySpent;
    timeToFinish = newTimeToFinish;
    // do{
    dest = MovingStar.offsetOutside(canvasRect, 200,
        xBase: basePosition.dx, yBase: basePosition.dy);
    // }while(!willIntersect(canvasRect, alreadySpent));
  }

  double size(int timeSpent) {
    return timeSpent / timeToFinish * endingSize;
  }

  Color calculatedColor(int timeSpent) {
    return ColorTween(begin: color, end: Colors.white)
        .lerp(timeSpent / timeToFinish)!;
  }
}
