import 'dart:math';

import 'package:flutter/material.dart';

class FogParticle {
  static const maxParticleDuration = Duration(milliseconds: 30000);
  static const minParticleDuration = Duration(milliseconds: 10000);

  Tween<Offset> tweenPosition;
  final Tween<double> tweenSize;
  final Color color;
  final Duration duration;
  DateTime startTime;

  FogParticle({
    required this.tweenPosition,
    required this.tweenSize,
    required this.color,
    required this.duration,
    required this.startTime,
  });

  FogParticle.random(Random rand, DateTime startTime, Size size)
      : duration = Duration(
    milliseconds: (rand.nextDouble() *
        (maxParticleDuration - minParticleDuration)
            .inMilliseconds +
        minParticleDuration.inMilliseconds)
        .round(),
  ),
        startTime = startTime.add(
          Duration(
              milliseconds:
              (rand.nextDouble() * maxParticleDuration.inMilliseconds / 2)
                  .round()),
        ),
        tweenPosition = Tween<Offset>(
            begin: FogParticle.offsetOutside(size, size.shortestSide * 0.25),
            end: FogParticle.offsetOutside(size, size.shortestSide * 0.25)),
        tweenSize = Tween<double>(
          begin: size.shortestSide * (0.05 + rand.nextDouble() * 0.2),
          end: size.shortestSide * (0.05 + rand.nextDouble() * 0.2),
        ),
        color = Colors.white54;

  bool willIntersect(Rect canvasRect) {
    Offset currentPos = tweenPosition.begin!;
    Offset laterPos = tweenPosition.end!;
    Path p = Path();
    p.moveTo(currentPos.dx, currentPos.dy);
    p.lineTo(laterPos.dx, laterPos.dy);
    p.close();
    final intersect =
    Path.combine(PathOperation.intersect, p, Path()
      ..addRect(canvasRect));
    return !intersect
        .getBounds()
        .size
        .isEmpty;
  }

  static Offset offsetOutside(Size size, double distance,
      {double? xBase, double? yBase, bool allowInside = false}) {
    final canvasRect = Offset.zero & size;
    var biggerRect = Rect.fromCenter(
        center: canvasRect.center,
        width: canvasRect.width + distance,
        height: canvasRect.height + distance);

    Random rand = Random();
    double newX;
    do {
      newX =
          rand.nextDouble() * (canvasRect.width + 4 * distance) - 2 * distance;
    } while (biggerRect.contains(Offset(newX, biggerRect.center.dy)));

    double newY;
    do {
      newY =
          rand.nextDouble() * (canvasRect.height + 4 * distance) - 2 * distance;
    } while (biggerRect.contains(Offset(biggerRect.center.dx, newY)));

    return Offset(newX, newY);
  }

  static Offset offsetOutsideOld(Size size, double distance,
      {double? xBase, double? yBase, bool allowInside = false}) {
    final canvasRect = Offset.zero & size;
    var biggerRect = Rect.fromCenter(
        center: canvasRect.center,
        width: canvasRect.width + distance,
        height: canvasRect.height + distance);
    var p = Path.combine(PathOperation.difference, Path()
      ..addRect(biggerRect),
        Path()
          ..addRect(canvasRect));

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

  void recreateElsewhere(Size size, int distance) {
    startTime = DateTime.now();
    tweenPosition = Tween<Offset>(
        begin: FogParticle.offsetOutside(size, size.shortestSide * 0.25),
        end: FogParticle.offsetOutside(size, size.shortestSide * 0.25));
  }

  double _progress(DateTime currentTime) {
    if (currentTime.isBefore(startTime)) {
      return 0;
    } else {
      final endTime = startTime.add(duration);
      final diff = endTime.difference(currentTime);
      if (diff.isNegative) {
        // print('progress negative');
        return 1;
      } else {
        // print('progress: ${diff.inMilliseconds / duration.inMilliseconds}');
        return diff.inMilliseconds / duration.inMilliseconds;
      }
    }
  }

  Offset position(DateTime currentTime) {
    return tweenPosition.transform(_progress(currentTime));
  }

  double size(DateTime currentTime) {
    return tweenSize.transform(_progress(currentTime));
  }

  bool hasReachedDest(DateTime currentTime) {
    return _progress(currentTime) >= 1;
  }
}
