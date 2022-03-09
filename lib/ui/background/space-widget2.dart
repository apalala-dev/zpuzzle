import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:slide_puzzle/hover-effect.dart';
import 'package:slide_puzzle/ui/background/moving-star.dart';
import 'package:slide_puzzle/puzzle-board-widget.dart';
import 'package:supercharged/supercharged.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:image/image.dart' as imglib;

import '../../model/puzzle.dart';

class SpaceWidget2 extends StatefulWidget {
  const SpaceWidget2({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _SpaceWidgetState();
}

class _SpaceWidgetState extends State<SpaceWidget2> {
  final List<MovingStar> _movingStars = [];
  Timer? refreshTimer;
  int _timeSpent = 0;
  Offset? _mousePosition;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Size size = MediaQuery.of(context).size;
      var canvasRect = Offset.zero & size;
      print(
          "canvasRect - center: ${canvasRect.center} - w:${canvasRect.width}, h: ${canvasRect.height}");
      var rand = Random();

      // for (int i = 0; i < 50; i++) {
      //   _movingStars.add(MovingStar(
      //     basePosition: MovingStar.offsetInCenter(canvasRect, canvasRect.width),
      //     dest: MovingStar.offsetOutside(canvasRect, 200, allowInside: true),
      //     size: max(2, rand.nextDouble() * 7),
      //     color: Colors.white.withOpacity(max(rand.nextDouble() * 0.8, 0.5)),
      //     timeToFinish: max(10000, (rand.nextDouble() * 5000).round()),
      //     distance: rand.nextInt((canvasRect.size.shortestSide / 2).round()),
      //   ));
      // }

      for (int i = 0; i < 25; i++) {
        final startingSize = max(2.0, rand.nextDouble() * 7);
        _movingStars.add(MovingStar(
          basePosition: MovingStar.offsetInCenter(canvasRect, 100),
          dest: MovingStar.offsetOutside(canvasRect, 50, allowInside: true),
          startingSize: startingSize,
          endingSize: startingSize + rand.nextDouble() * 10,
          color: Colors.white.withOpacity(max(rand.nextDouble() * 0.8, 0.5)),
          timeToFinish: 10000 + (rand.nextDouble() * 5000).round(),
          distance: rand.nextInt((canvasRect.size.shortestSide / 2).round()),
        ));
      }

      for (int i = 0; i < 25; i++) {
        final startingSize = max(0.1, rand.nextDouble() * 7);
        _movingStars.add(MovingStar(
          basePosition: MovingStar.offsetInCenter(canvasRect, 100),
          dest: MovingStar.offsetOutside(canvasRect, 50, allowInside: true),
          startingSize: startingSize,
          endingSize: startingSize + rand.nextDouble() * 10,
          color: Colors.white.withOpacity(max(rand.nextDouble() * 0.8, 0.5)),
          timeToFinish: 20000 + (rand.nextDouble() * 50000).round(),
          distance: rand.nextInt((canvasRect.size.shortestSide / 2).round()),
        ));
      }

      var nbMillisEachTick = (1.seconds.inMilliseconds / 60).round();
      refreshTimer = Timer.periodic(nbMillisEachTick.milliseconds, (timer) {
        setState(() {
          _timeSpent = timer.tick * nbMillisEachTick;
          // _timeSpent = 0;
        });
      });

      gyroscopeEvents.listen((GyroscopeEvent event) {
        // print("gyro: ${event.x}, ${event.y}, ${event.z}");
        // _mousePosition = Offset(event.x * 100, event.y * 100);
      });
      // _loadImage();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var canvasRect = Offset.zero & MediaQuery.of(context).size;
    double percentInclinaisonY = (_mousePosition != null
        ? (_mousePosition!.dx - canvasRect.center.dx) / 5
        : 0.0);
    return CustomPaint(
        painter: _GalaxyPainter(
            _movingStars,
            _timeSpent,
            Curves.linear.transform(cos(_timeSpent.toDouble()).abs()),
            _mousePosition));

    return MouseRegion(
      child: CustomPaint(
          painter: _GalaxyPainter(
              _movingStars,
              _timeSpent,
              Curves.linear.transform(cos(_timeSpent.toDouble()).abs()),
              _mousePosition)),
      onHover: (event) {
        // print("hover ${event.position}");
        // setState(() {
        // _mousePosition = event.position;
        // });
      },
    );
  }
}

class _GalaxyPainter extends CustomPainter {
  List<MovingStar> movingStars;
  int timeSpent;
  double animValue;
  Offset? mousePosition;

  _GalaxyPainter(
    this.movingStars,
    this.timeSpent,
    this.animValue,
    this.mousePosition,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF0C1639), BlendMode.src);
    var canvasRect = Offset.zero & size;
    var biggerRect = Rect.fromCenter(
        center: canvasRect.center,
        width: canvasRect.width + 50,
        height: canvasRect.height + 50);

    if (movingStars.isNotEmpty) {
      Random rand = Random();
      for (var s in movingStars) {
        final calculatedPosition = s.calculatedPosition(timeSpent,
            mousePosition: mousePosition, center: canvasRect.center);
        final calculatedSize = s.size(timeSpent);
        final calculatedColor = s.calculatedColor(timeSpent);
        if (biggerRect.contains(calculatedPosition)) {
          canvas.drawCircle(
            calculatedPosition,
            calculatedSize,
            Paint()
              ..color = s.color
              ..shader = RadialGradient(
                      colors: [s.color, Colors.transparent],
                      stops: const [0.8, 0.1])
                  .createShader(Rect.fromCenter(
                      center: calculatedPosition,
                      width: calculatedSize,
                      height: calculatedSize)),
          );
        } else {
          // print("not in rect");
          if (rand.nextDouble() > 0.3) {
            s.recreateElsewhere(
              canvasRect,
              50,
              timeSpent,
              max(100000, (rand.nextDouble() * 500000).round()),
            );
          } else {
            s.recreateElsewhere(
              Rect.fromCenter(
                  center: canvasRect.center, width: 100, height: 100),
              50,
              timeSpent,
              max(100000, (rand.nextDouble() * 500000).round()),
            );
            s.startingSize = 0.1;
            s.startingSize = s.startingSize + rand.nextDouble() * 10;
          }
          // print(
          //     "Recreated: ${s.basePosition} - calculated: ${s.calculatedPosition(timeSpent)}, in rect: ${canvasRect.contains(s.calculatedPosition(timeSpent))}");
        }
      }
    }
    return;

    var basePaint = Paint()..color = Colors.green;
    double circleSize = size.width / 20;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawRect(
        Rect.fromCenter(
            center: center, width: size.width / 4, height: size.width / 4),
        basePaint);
    // canvas.drawColor(Colors.red, BlendMode.multiply);
    canvas.drawCircle(
      center,
      circleSize,
      Paint()
        ..color = Colors.white
        ..shader = RadialGradient(
          colors: [
            basePaint.color.lighter(5),
            basePaint.color.darker(6),
          ],
          stops: const [1, 0.8],
        ).createShader(
          Rect.fromCenter(
              center: center, width: circleSize, height: circleSize),
        ),
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - 50),
      circleSize * 10,
      Paint()
        // ..color = Colors.w
        ..shader = RadialGradient(
          colors: [
            Colors.yellow,
            Colors.white.darker(30),
          ],
          // stops: const [, 1],
        ).createShader(
          Rect.fromCenter(
              center: Offset(center.dx, center.dy - 50),
              width: circleSize * 10,
              height: circleSize * 10),
        )
        ..blendMode = BlendMode.softLight,
    );
    canvas.drawShadow(
        Path()
          ..addOval(Rect.fromCenter(
              center: center, width: circleSize * 3, height: circleSize)),
        Colors.blue,
        8,
        true);

    var rand = Random();
    // List<Offset> fogPoints = [
    //   for (int i = 0; i < 200; i++)
    //     Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height)
    // ];
    // Path fogPath = Path();
    // fogPath.moveTo(fogPoints[0].dx, fogPoints[0].dy);
    //
    // for (int i = 1; i < fogPoints.length; i++) {
    //   fogPath.lineTo(fogPoints[i].dx, fogPoints[i].dy);
    // }
    // fogPath.close();
    // canvas.drawShadow(fogPath, Colors.white30, 8, false);

    // List<Offset> starPoints = [
    //   for (int i = 0; i < 200; i++)
    //     Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height)
    // ];

    for (var s in movingStars) {
      var calculatedPosition = s.calculatedPosition(timeSpent);
      if (canvasRect.contains(calculatedPosition)) {
        canvas.drawCircle(
          calculatedPosition,
          s.startingSize,
          Paint()
            ..color = s.color
            ..shader = const RadialGradient(
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.8, 0.1])
                .createShader(Rect.fromCenter(
                    center: s.calculatedPosition(timeSpent),
                    width: s.startingSize,
                    height: s.startingSize)),
        );
      } else {
        if (!s.willIntersect(canvasRect, timeSpent)) {
          // s.changeDirectionToIntersect(canvasRect, timeSpent);
          print("il faudrait changer");
        } else {
          print("izokay");

          // print(
          //     "willintersect: ${s.calculatedPosition(timeSpent)} to ${s.calculatedPosition(timeSpent + 10.seconds.inMilliseconds)} - Rect={${canvasRect.topLeft}, ${canvasRect.bottomRight}");
        }
        var curPos = s.calculatedPosition(timeSpent);
        // canvas.drawLine(
        //     curPos,
        //     s.calculatedPosition(0),
        //     Paint()
        //       ..color = Colors.green
        //       ..strokeWidth = 3);

        Path p = Path();
        // p.moveTo(curPos.dx, curPos.dy);
        // p.lineTo(s.calculatedPosition(0).dx, s.calculatedPosition(0).dy);
        // p.close();
        p.addPolygon([
          curPos,
          Offset(curPos.dx + 0.1, curPos.dy + 0.1),
          s.calculatedPosition(0),
          Offset(s.calculatedPosition(0).dx + 0.11,
              s.calculatedPosition(0).dy + 0.1)
        ], false);
        canvas.drawPath(
            p,
            Paint()
              ..color = Colors.purple
              ..style = PaintingStyle.stroke
              ..strokeWidth = 10);
      }
      // canvas.drawShadow(
      //     Path()
      //       ..addOval(Rect.fromCenter(
      //           center: s,
      //           width: rand.nextDouble() * size.width / 180,
      //           height: rand.nextDouble() * size.width / 180)),
      //     Colors.black26,
      //     8,
      //     false);
    }

    Path oval = Path();
    oval.addOval(
      Rect.fromCenter(
          center: center, width: size.width / 10, height: size.width / 5),
    );
    // canvas.drawCircle(calculate(oval, animValue), size.width / 100,
    //     Paint()..color = Colors.pink);
  }

  Offset calculate(Path path, double value) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    ui.PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    ui.Tangent? pos = pathMetric.getTangentForOffset(value);
    return pos!.position;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}