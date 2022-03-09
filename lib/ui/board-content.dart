import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/tiles/maybe-move-transition.dart';
import 'package:slide_puzzle/ui/tiles/puzzle-tile-any-widget.dart';
import 'package:zwidget/zwidget.dart';

import '../model/position.dart';

class BoardContent extends StatefulWidget {
  final Size contentSize;
  final Puzzle puzzle;
  final Widget backgroundWidget;
  final Function(Tile) onTileMoved;
  final double xTilt;
  final double yTilt;
  final bool showIndicator;

  const BoardContent({
    Key? key,
    required this.contentSize,
    required this.puzzle,
    required this.backgroundWidget,
    required this.onTileMoved,
    required this.xTilt,
    required this.yTilt,
    this.showIndicator = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BoardContentState();
  }
}

class _BoardContentState extends State<BoardContent> {
  @override
  Widget build(BuildContext context) {
    final canvasRect = Offset.zero & widget.contentSize;
    final nbColumns = widget.puzzle.getDimension();
    final innerBoardSpacing = widget.contentSize.shortestSide / 30;
    final tileSpacing = widget.contentSize.shortestSide / 150;
    final squareSize = ((widget.contentSize.shortestSide -
            (nbColumns * tileSpacing * 2) -
            innerBoardSpacing * 2 * 2) /
        nbColumns);

    final topChild = SizedBox(
      child: Stack(children: [
        ...List.generate(nbColumns * nbColumns, (idx) {
          var tile = widget.puzzle.tiles[idx];

          var content = SizedBox(
              child: idx == nbColumns * nbColumns - 1
                  ? null
                  :
                  // ClipRRect(
                  //         borderRadius: BorderRadius.circular(
                  //             widget.contentSize.shortestSide / 50),
                  //         child:
                  PuzzleTileAnyWidget(
                      tile,
                      key: ValueKey(tile.value),
                      xTilt: widget.xTilt,
                      yTilt: widget.yTilt,
                      canvasRect: canvasRect,
                      tileSize: squareSize,
                      tileSpacing: tileSpacing,
                      percentDepth: 1,
                      percentOpacity: 1,
                      borderRadius: BorderRadius.circular(
                          widget.contentSize.shortestSide / 30),
                      nbTiles: widget.puzzle.getDimension(),
                      child: widget.backgroundWidget,
                      onTap: () {
                        if (widget.puzzle.isTileMovable(tile)) {
                          widget.onTileMoved(tile);
                        }
                      },
                      showIndicator: widget.showIndicator,
                      // ),
                    ),
              width: squareSize,
              height: squareSize);

          return MaybeMoveTransition(
              tile: tile,
              child: content,
              // child: tile.isWhitespace
              //     ? Container()
              //     : Container(
              //         child: Center(child: Text('${tile.value}')),
              //         color: Colors.pink,
              //         width: squareSize,
              //         height: squareSize),
              tileSize: squareSize + tileSpacing * 2,
              onAnimationEnd: () {
                // setState(() {
                widget.puzzle.tiles[idx] = widget.puzzle.tiles[idx].copyWith(
                    newPreviousPosition:
                        widget.puzzle.tiles[idx].currentPosition);
                // });
              });
        }),
      ]),
      // width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
      // height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
      width: widget.contentSize.shortestSide,
      height: widget.contentSize.shortestSide,
    );

    return ZWidget(
      // midChild: Container(
      //   width: widget.contentSize.width,
      //   height: widget.contentSize.width,
      //   color: Colors.pink,
      // ),
      // midToTopChild: Container(
      //   width: widget.contentSize.width,
      //   height: widget.contentSize.width,
      //   color: Colors.red,
      // ),
      midChild: SizedBox(
        child: Stack(children: [
          ...List.generate(nbColumns * nbColumns, (idx) {
            var tile = widget.puzzle.tiles[idx];

            var content = SizedBox(
                child: idx == nbColumns * nbColumns - 1
                    ? null
                    :
                    // ClipRRect(
                    //         borderRadius: BorderRadius.circular(
                    //             widget.contentSize.shortestSide / 50),
                    //         child:
                    Padding(
                        child: Container(
                            width: squareSize,
                            height: squareSize,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(
                                  widget.contentSize.shortestSide / 30),
                            )),
                        padding: EdgeInsets.all(tileSpacing),
                      ),
                width: squareSize,
                height: squareSize);

            return MaybeMoveTransition(
                tile: tile,
                child: content,
                tileSize: squareSize + tileSpacing * 2,
                onAnimationEnd: () {
                  setState(() {
                    widget.puzzle.tiles[idx] = widget.puzzle.tiles[idx]
                        .copyWith(
                            newPreviousPosition:
                                widget.puzzle.tiles[idx].currentPosition);
                  });
                });
          }),
        ]),
        // width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        // height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        width: widget.contentSize.shortestSide,
        height: widget.contentSize.shortestSide,
      ),
      topChild: SizedBox(
        child: Stack(children: [
          ...List.generate(nbColumns * nbColumns, (idx) {
            var tile = widget.puzzle.tiles[idx];

            var content = SizedBox(
                child: idx == nbColumns * nbColumns - 1
                    ? null
                    :
                    // ClipRRect(
                    //         borderRadius: BorderRadius.circular(
                    //             widget.contentSize.shortestSide / 50),
                    //         child:
                    PuzzleTileAnyWidget(
                        tile,
                        key: ValueKey(tile.value),
                        xTilt: widget.xTilt,
                        yTilt: widget.yTilt,
                        canvasRect: canvasRect,
                        tileSize: squareSize,
                        tileSpacing: tileSpacing,
                        percentDepth: 1,
                        percentOpacity: 1,
                        borderRadius: BorderRadius.circular(
                            widget.contentSize.shortestSide / 30),
                        nbTiles: widget.puzzle.getDimension(),
                        child: widget.backgroundWidget,
                        onTap: () {
                          if (widget.puzzle.isTileMovable(tile)) {
                            widget.onTileMoved(tile);
                          }
                        },
                        showIndicator: widget.showIndicator,
                        // ),
                      ),
                width: squareSize,
                height: squareSize);

            return MaybeMoveTransition(
                tile: tile,
                child: content,
                // child: tile.isWhitespace
                //     ? Container()
                //     : Container(
                //         child: Center(child: Text('${tile.value}')),
                //         color: Colors.pink,
                //         width: squareSize,
                //         height: squareSize),
                tileSize: squareSize + tileSpacing * 2,
                onAnimationEnd: () {
                  // setState(() {
                  widget.puzzle.tiles[idx] = widget.puzzle.tiles[idx].copyWith(
                      newPreviousPosition:
                          widget.puzzle.tiles[idx].currentPosition);
                  // });
                });
          }),
        ]),
        // width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        // height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        width: widget.contentSize.shortestSide,
        height: widget.contentSize.shortestSide,
      ),
      depth: 20,
      layers: 11,
      rotationX: 0,
      //pi/3,//widget.xTilt,
      rotationY: 0,
      //pi/4,//widget.yTilt,
      perspective: 0.5,
      direction: ZDirection.forwards,
    );
  }
}

class _BackgroundDepthPainter extends CustomPainter {
  final Puzzle puzzle;
  final double squareSize;
  final double tileSpacing;
  final Radius radius;

  _BackgroundDepthPainter(
    this.puzzle,
    this.squareSize,
    this.tileSpacing,
    this.radius,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()..color = Colors.greenAccent;
    final tileSize = squareSize - tileSpacing * 2;
    for (var t in puzzle.tiles) {
      if (t.isWhitespace) continue;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  tileSpacing +
                      (squareSize + tileSpacing * 2) *
                          (t.currentPosition.x - 1),
                  tileSpacing +
                      (squareSize + tileSpacing * 2) *
                          (t.currentPosition.y - 1),
                  tileSize,
                  tileSize),
              radius),
          _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
