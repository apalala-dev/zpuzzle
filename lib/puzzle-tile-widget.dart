import 'package:flutter/material.dart';
import 'package:flutter_color/src/helper.dart';
import 'package:slide_puzzle/z-widget.dart';
import 'package:slide_puzzle/ztext.dart';
import 'package:supercharged/supercharged.dart';

class PuzzleTileWidget extends StatelessWidget {
  final Offset? mousePosition;
  final Rect canvasRect;
  final int index;

  const PuzzleTileWidget(
    this.index, {
    Key? key,
    required this.mousePosition,
    required this.canvasRect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var canvasRect = Offset.zero & MediaQuery.of(context).size;

    Widget text = Text(
      "$index",
      style: TextStyle(fontSize: 54, color: Colors.white, shadows: [
        Shadow(
          color: Colors.teal.darker(50),
          offset: Offset(
              -0.02 *
                  (mousePosition != null
                      ? mousePosition!.dx - canvasRect.center.dx
                      : 0),
              -0.02 *
                  (mousePosition != null
                      ? mousePosition!.dy - canvasRect.center.dy
                      : 0)),
        )
      ]),
    );
    text = ZText(
      "$index",
      style: const TextStyle(fontSize: 72, color: Colors.white),
      yPercent: -0.02 *
          (mousePosition != null
              ? mousePosition!.dx - canvasRect.center.dx
              : 0) /
          (canvasRect.size.width / 2),
      xPercent: -0.02 *
          (mousePosition != null
              ? mousePosition!.dy - canvasRect.center.dy
              : 0) /
          (canvasRect.size.height / 2),
      depth: 0.5,
      direction: ZDirection.forwards,
      layers: 20,
      eventRotation: 30,
      reverse: false,
      fade: false,
    );

    text = ZWidget(
      child: Text("$index",
          style: const TextStyle(fontSize: 56, color: Colors.white)),
      belowChild: Text("$index",
          style: const TextStyle(fontSize: 56, color: Colors.white10)),
      aboveChild: Text("$index",
          style: const TextStyle(fontSize: 56, color: Colors.grey)),
      yPercent: -0.02 *
          (mousePosition != null
              ? mousePosition!.dx - canvasRect.center.dx
              : 0) /
          (canvasRect.size.width / 2),
      xPercent: -0.02 *
          (mousePosition != null
              ? mousePosition!.dy - canvasRect.center.dy
              : 0) /
          (canvasRect.size.height / 2),
      depth: 1.5,
      direction: ZDirection.both,
      layers: 10,
      eventRotation: 30,
      reverse: false,
      fade: false,
    );

    return Container(
      decoration: BoxDecoration(
          // color: Colors.white,
          // border: Border.all(width: 2, color: Colors.teal),
          ),
      child: Padding(
        child: Container(
          child: Center(
            child: text,
          ),
          decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.teal.darker(30),
                    offset: Offset(
                        -0.02 *
                            (mousePosition != null
                                ? mousePosition!.dx - canvasRect.center.dx
                                : 0),
                        -0.02 *
                            (mousePosition != null
                                ? mousePosition!.dy - canvasRect.center.dy
                                : 0)))
              ]),
        ),
        padding: const EdgeInsets.all(8),
      ),
    );
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(0.01 /
            5 *
            (mousePosition != null
                ? mousePosition!.dy - canvasRect.center.dy
                : 0))
        ..rotateY(-0.01 /
            5 *
            (mousePosition != null
                ? mousePosition!.dx - canvasRect.center.dx
                : 0)),
      alignment: FractionalOffset.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal,
              offset: Offset(
                  0.05 *
                      (mousePosition != null
                          ? mousePosition!.dx - canvasRect.center.dx
                          : 0),
                  0.05 *
                      (mousePosition != null
                          ? mousePosition!.dy - canvasRect.center.dy
                          : 0)),
            ),
          ],
          color: "E0E0E0".toColor(),
        ),
        width: 100,
        height: 100,
      ),
    );
  }

  _v1() {
    return Stack(children: [
      Positioned.fill(
          child: Center(
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.01 /
                5 *
                (mousePosition != null
                    ? mousePosition!.dy - canvasRect.center.dy
                    : 0))
            ..rotateY(-0.01 /
                5 *
                (mousePosition != null
                    ? mousePosition!.dx - canvasRect.center.dx
                    : 0)),
          alignment: FractionalOffset.center,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal,
                    offset: Offset(
                        0.05 *
                            (mousePosition != null
                                ? mousePosition!.dx - canvasRect.center.dx
                                : 0),
                        0.05 *
                            (mousePosition != null
                                ? mousePosition!.dy - canvasRect.center.dy
                                : 0)),
                  ),
                ],
                color: "E0E0E0".toColor(),
              ),
              width: 100,
              height: 100,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 100,
                    spreadRadius: -10,
                    offset: Offset(
                        0.05 *
                            (mousePosition != null
                                ? mousePosition!.dx - canvasRect.center.dx
                                : 0),
                        0.05 *
                            (mousePosition != null
                                ? mousePosition!.dy - canvasRect.center.dy
                                : 0)),
                  ),
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 100,
                    spreadRadius: -50,
                    offset: Offset(
                        -0.05 *
                            (mousePosition != null
                                ? mousePosition!.dx - canvasRect.center.dx
                                : 0),
                        -0.05 *
                            (mousePosition != null
                                ? mousePosition!.dy - canvasRect.center.dy
                                : 0)),
                  ),
                ],
                color: Colors.transparent,
              ),
              width: 100,
              height: 100,
            ),
          ]),
        ),
      ))
    ]);
  }
}
