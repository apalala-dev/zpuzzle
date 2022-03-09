import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/rive/speed_controller.dart';
import 'package:supercharged/supercharged.dart';
import 'package:zwidget/zwidget.dart';

import 'tiles/puzzle-tile-any-widget.dart';

class PuzzleBoardWidget extends StatefulWidget {
  final Puzzle puzzle;
  final ImageProvider imageProvider;
  final double imgSize;
  final List<Animation<double>> tileEnterAnimation;
  final List<Animation<double>> tileLetterDepthAnimation;
  final List<Animation<double>> tileLetterFadeAnimation;
  final Animation<Offset> boardMoveAnim;
  final Animation<double> flipAnimation;
  final bool exiting;
  final Widget? backgroundWidget;

  const PuzzleBoardWidget({
    Key? key,
    required this.puzzle,
    required this.tileEnterAnimation,
    required this.tileLetterDepthAnimation,
    required this.tileLetterFadeAnimation,
    required this.flipAnimation,
    required this.imageProvider,
    required this.imgSize,
    required this.exiting,
    required this.boardMoveAnim,
    this.backgroundWidget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleBoardWidgetState();
  }
}

class _PuzzleBoardWidgetState extends State<PuzzleBoardWidget> {
  late RiveAnimationController riveController;

  @override
  void initState() {
    super.initState();
    riveController =
        SpeedController('Animation 1', speedMultiplier: 1 / 10, autoplay: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return LayoutBuilder(builder: (ctx, constraints) {
      var contentSize = Size(constraints.maxWidth, constraints.maxHeight);
      final boardSpacing = 0.0;
      final innerBoardSpacing = contentSize.shortestSide / 30;
      final nbColumns = widget.puzzle.getDimension();
      final tileSpacing = contentSize.shortestSide / 100;
      final squareSize = ((contentSize.shortestSide -
              (nbColumns - 1) * tileSpacing -
              boardSpacing * 2 * 2 -
              innerBoardSpacing * 2 * 2 -
              58) /
          nbColumns);

      final yTilt = widget.flipAnimation.value;

      Widget tiltedContent = ZWidget(
        debug: true,
        rotationY: 0,
        rotationX: yTilt,
        alignment: Alignment.bottomCenter,
        depth: 0.05 * contentSize.shortestSide,
        direction: ZDirection.backwards,
        layers: 10,
        midChild: Container(
          child: Container(
            child: _boardTiles(
              screenSize: screenSize,
              nbColumns: nbColumns,
              contentSize: contentSize,
              squareSize: squareSize,
              tileSpacing: tileSpacing,
              xTilt: 0,
              yTilt: yTilt,
            ),
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
              borderRadius:
                  BorderRadius.circular(contentSize.shortestSide / 30)),
        ),
        midToBotChild: Container(
          width: innerBoardSpacing * 4 +
              squareSize * nbColumns +
              tileSpacing * (nbColumns - 1),
          height: innerBoardSpacing * 4 +
              squareSize * nbColumns +
              tileSpacing * (nbColumns - 1),
          padding: EdgeInsets.all(innerBoardSpacing),
          decoration: BoxDecoration(
            color: HexColor("D0D0D0"),
            borderRadius: BorderRadius.circular(contentSize.shortestSide / 30),
          ),
        ),
      );
      tiltedContent = ZWidget(
        debug: true,
        rotationY: 0,
        rotationX: yTilt,
        alignment: Alignment.bottomCenter,
        depth: 0.05 * contentSize.shortestSide,
        direction: ZDirection.backwards,
        layers: 10,
        midChild: Container(
          child: Container(
            child: _boardTiles(
              screenSize: screenSize,
              nbColumns: nbColumns,
              contentSize: contentSize,
              squareSize: squareSize,
              tileSpacing: tileSpacing,
              xTilt: 0,
              yTilt: yTilt,
            ),
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
              borderRadius:
                  BorderRadius.circular(contentSize.shortestSide / 30)),
        ),
      );

      return Transform.translate(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(boardSpacing), child: tiltedContent)),
        offset: widget.boardMoveAnim.value,
      );
    });
  }

  Widget _boardTiles({
    required int nbColumns,
    required Size screenSize,
    required double xTilt,
    required double yTilt,
    required double squareSize,
    required double tileSpacing,
    required Size contentSize,
  }) {
    if (false)
      return Container(
        width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
        color: Colors.pink,
        // width: 20, height: 20,
      );
    final canvasRect = Offset.zero & contentSize;

    return SizedBox(
      child: Stack(children: [
        ...List.generate(nbColumns * nbColumns, (idx) {
          var tile = widget.puzzle.tiles[idx];
          var scaledTile = Tween(
                  begin: widget.exiting ? 1.0 : 0.1,
                  end: widget.exiting ? 0.0 : 1.0)
              .evaluate(widget.tileEnterAnimation[tile.value - 1]);
          var yOffset = -Tween(
                  begin: widget.exiting ? 0.0 : -screenSize.longestSide,
                  end: widget.exiting ? -screenSize.longestSide : 0.0)
              .evaluate(widget.tileEnterAnimation[tile.value - 1]);
          var zOffset = Tween(
                  begin: widget.exiting ? 0.0 : -screenSize.longestSide,
                  end: widget.exiting ? -screenSize.longestSide : 0.0)
              .evaluate(widget.tileEnterAnimation[tile.value - 1]);
          var percentDepthText =
              widget.tileLetterDepthAnimation[tile.value - 1].value;
          var percentOpacityText =
              widget.tileLetterFadeAnimation[tile.value - 1].value;

          var content = SizedBox(
              child: idx == nbColumns * nbColumns - 1
                  ? null
                  : Transform(
                      transform: Matrix4.identity()
                        ..translate(
                          0.0,
                          yOffset,
                          zOffset,
                        )
                        ..scale(scaledTile),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              contentSize.shortestSide / 50),
                          child: PuzzleTileAnyWidget(
                            tile,
                            xTilt: 0,
                            yTilt: 0,
                            canvasRect: canvasRect,
                            tileSize: squareSize,
                            tileSpacing: tileSpacing,
                            imageProvider: widget.imageProvider,
                            imgSize: widget.imgSize,
                            percentDepth: percentDepthText,
                            percentOpacity: percentOpacityText,
                            nbTiles: widget.puzzle.getDimension(),
                            borderRadius: BorderRadius.circular(
                                contentSize.shortestSide / 30),
                            child: widget.backgroundWidget ??
                                RiveAnimation.asset(
                                  'assets/rive/earth.riv',
                                  fit: BoxFit.cover,
                                  controllers: [riveController],
                                ),
                            onTap: () {
                              // print("Gonna move tile $tile");
                              if (widget.puzzle.isTileMovable(tile)) {
                                // print("movable tile $tile");
                                setState(() {
                                  widget.puzzle.moveTiles(tile);
                                  // print("tile moved $tile");
                                });
                              }
                            },
                          )),
                    ),
              width: squareSize,
              height: squareSize);

          // return widget.backgroundWidget!;
          if (false)
            return AnimatedPositioned(
              child: SizedBox(
                  child: idx == nbColumns * nbColumns - 1
                      ? null
                      : Transform(
                          transform: Matrix4.identity()
                            ..translate(
                              0.0,
                              yOffset,
                              zOffset,
                            )
                            ..scale(scaledTile),
                          child: Container(
                              color: Colors.pink,
                              child: Center(
                                  child: ZWidget(
                                midChild: Text("8",
                                    style: TextStyle(
                                        fontSize: squareSize / 2,
                                        color: Colors.white)),
                                midToBotChild: Text("8",
                                    style: TextStyle(
                                        fontSize: squareSize / 2,
                                        color: HexColor("999999"))),
                                rotationY: 0,
                                rotationX: 0,
                                depth: 8,
                                direction: ZDirection.backwards,
                                layers: 10,
                              )))),
                  width: squareSize,
                  height: squareSize),
              duration: 400.milliseconds,
              curve: Curves.fastOutSlowIn,
              left: (squareSize + tileSpacing) * (tile.currentPosition.x - 1),
              top: (squareSize + tileSpacing) * (tile.currentPosition.y - 1),
            );

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
  }
}
