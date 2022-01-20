import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:slide_puzzle/model/position.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/puzzle-tile-widget.dart';
import 'package:slide_puzzle/z-widget.dart';
import 'package:supercharged/supercharged.dart';
import 'package:image/image.dart' as imglib;

class PuzzleBoardWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Offset? mousePosition;
  final List<Image>? images;
  final double? xPercent;
  final double? yPercent;
  final Animation<double> tileEnterAnimation;
  final Animation<double> flipAnimation;

  const PuzzleBoardWidget({
    Key? key,
    required this.mousePosition,
    required this.puzzle,
    required this.tileEnterAnimation,
    required this.flipAnimation,
    this.images,
    this.xPercent,
    this.yPercent,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleBoardWidgetState();
  }
}

class _PuzzleBoardWidgetState extends State<PuzzleBoardWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      var size = Size(constraints.maxWidth, constraints.maxHeight);

      // var size = Size(200,200);
      var canvasRect = Offset.zero & size;
      const boardSpacing = 40.0; //20.0;
      const innerBoardSpacing = 16.0; //8.0;

      Widget boardTiles;

      var nbColumns = widget.puzzle.getDimension();
      var tileSpacing = size.shortestSide / 200;
      var squareSize = ((size.shortestSide -
              (nbColumns - 1) * tileSpacing -
              boardSpacing * 2 * 2 -
              innerBoardSpacing * 2 * 2 -
              58) /
          nbColumns);
      squareSize = 70;

      var xTilt = widget.xPercent ??
          -0.02 *
              (widget.mousePosition != null
                  ? widget.mousePosition!.dx - canvasRect.center.dx
                  : 0);
      var yTilt = widget.yPercent ??
          -0.02 *
              (widget.mousePosition != null
                  ? widget.mousePosition!.dy - canvasRect.center.dy
                  : 0);

      xTilt = Tween<double>(begin: 2 * xTilt, end: xTilt)
          .evaluate(widget.flipAnimation);
      yTilt = Tween<double>(begin: 2 * yTilt, end: yTilt)
          .evaluate(widget.flipAnimation);

      var scaledTile =
          Tween(begin: 0.1, end: 1).evaluate(widget.tileEnterAnimation);

      boardTiles = SizedBox(
        child: Stack(children: [
          ...List.generate(nbColumns * nbColumns, (idx) {
            var tile = widget.puzzle.tiles[idx];
            var content = SizedBox(
                child: idx == nbColumns * nbColumns - 1
                    ? null
                    : Transform(
                        transform: Matrix4.identity()
                          ..translate(
                              0,
                              -Tween(begin: -1000.0, end: 0.0)
                                  .evaluate(widget.tileEnterAnimation),
                              Tween(begin: -1000.0, end: 0.0)
                                  .evaluate(widget.tileEnterAnimation))
                          ..scale(scaledTile),
                        child: PuzzleTileWidget(
                          tile.value,
                          xTilt: xTilt,
                          yTilt: yTilt,
                          canvasRect: canvasRect,
                          tileSize: squareSize,
                          tileSpacing: tileSpacing,
                          image: widget.images?[tile.value - 1],
                          onTap: () {
                            print("Gonna move tile $tile");
                            if (widget.puzzle.isTileMovable(tile)) {
                              print("movable tile $tile");
                              setState(() {
                                widget.puzzle.moveTiles(tile, []);
                                print("tile moved $tile");
                              });
                            }
                          },
                        )),
                width: squareSize,
                height: squareSize);
            return AnimatedPositioned(
              child: content,
              duration: 400.milliseconds,
              curve: Curves.fastOutSlowIn,
              left: (squareSize + tileSpacing) * (tile.currentPosition.x - 1),
              top: (squareSize + tileSpacing) * (tile.currentPosition.y - 1),
            );
          }),
        ]),
        width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
      );

      var newContent = ZWidget(
          debug: false,
          yPercent: xTilt,
          xPercent: yTilt,
          depth: 0.05 * size.shortestSide,
          perspective: 20,
          direction: ZDirection.backwards,
          layers: 10,
          eventRotation: 20,
          aboveChild: Container(
            width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
            height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
            padding: const EdgeInsets.all(innerBoardSpacing),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          belowChild: Container(
            width: innerBoardSpacing * 4 +
                squareSize * nbColumns +
                tileSpacing * (nbColumns - 1),
            height: innerBoardSpacing * 4 +
                squareSize * nbColumns +
                tileSpacing * (nbColumns - 1),
            padding: const EdgeInsets.all(innerBoardSpacing),
            decoration: BoxDecoration(
              color: HexColor("D0D0D0"),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Container(
            child: Container(
              child: boardTiles,
              padding: const EdgeInsets.all(innerBoardSpacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(xTilt * 0.01 * size.shortestSide,
                          yTilt * 0.01 * size.shortestSide))
                ],
              ),
            ),
            padding: const EdgeInsets.all(innerBoardSpacing),
            decoration: BoxDecoration(
                color: HexColor("E0E0E0"),
                // boxShadow: [
                //   BoxShadow(
                //       color: Colors.black54,
                //       offset: Offset(
                //           0.03 *
                //               (widget.mousePosition != null
                //                   ? widget.mousePosition!.dx -
                //                       canvasRect.center.dx
                //                   : 0),
                //           0.03 *
                //               (widget.mousePosition != null
                //                   ? widget.mousePosition!.dy -
                //                       canvasRect.center.dy
                //                   : 0)))
                // ],
                borderRadius: BorderRadius.circular(16)),
          ));

      return Center(
          child: Padding(
              padding: const EdgeInsets.all(boardSpacing), child: newContent));
    });
  }
}
