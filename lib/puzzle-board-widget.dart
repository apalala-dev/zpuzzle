import 'package:flutter/material.dart';
import 'package:slide_puzzle/puzzle-tile-widget.dart';
import 'package:supercharged/supercharged.dart';

class PuzzleBoardWidget extends StatelessWidget {
  final Offset? mousePosition;

  const PuzzleBoardWidget({Key? key, required this.mousePosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var canvasRect = Offset.zero & size;
    return Center(
      child: Padding(
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
              child: Container(
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, idx) {
                      return PuzzleTileWidget(idx,
                          mousePosition: mousePosition, canvasRect: canvasRect);
                    }),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          offset: Offset(
                              0.03 *
                                  (mousePosition != null
                                      ? mousePosition!.dx - canvasRect.center.dx
                                      : 0),
                              0.03 *
                                  (mousePosition != null
                                      ? mousePosition!.dy - canvasRect.center.dy
                                      : 0)))
                    ],
                    borderRadius: BorderRadius.circular(16)),
              ),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal,
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
                color: "E9E9E9".toColor(),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white70,
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
                        // BoxShadow(
                        //   color: Colors.black,
                        //   blurRadius: 100,
                        //   spreadRadius: -50,
                        //   offset: Offset(
                        //       -0.05 *
                        //           (mousePosition != null
                        //               ? mousePosition!.dx - canvasRect.center.dx
                        //               : 0),
                        //       -0.05 *
                        //           (mousePosition != null
                        //               ? mousePosition!.dy - canvasRect.center.dy
                        //               : 0)),
                        // ),
                      ],
                      color: Colors.transparent,
                    ),
                    width: size.shortestSide * 0.8,
                    height: size.shortestSide * 0.8,
                  ),
                ),
              ),
            ),
          ]),
        ),
        padding: EdgeInsets.all(20),
      ),
    );
  }
}
