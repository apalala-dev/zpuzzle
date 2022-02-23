import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/rive/speed_controller.dart';
import 'package:supercharged/supercharged.dart';
import 'package:zwidget/zwidget.dart';

import 'tiles/puzzle-tile-any-widget.dart';

class AltPuzzleBoardWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Widget? backgroundWidget;

  const AltPuzzleBoardWidget({
    Key? key,
    required this.puzzle,
    this.backgroundWidget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AltPuzzleBoardWidgetState();
  }
}

class _AltPuzzleBoardWidgetState extends State<AltPuzzleBoardWidget> {
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

      final xTilt = pi / 4;
      final yTilt = pi / 4;

      Widget tiltedContent = ZWidget(
        debug: true,
        rotationY: xTilt,
        rotationX: yTilt,
        alignment: Alignment.bottomRight,
        perspective: 1,
        depth: 0.05 * contentSize.shortestSide,
        direction: ZDirection.backwards,
        layers: 10,
        child: Container(
          child: Container(
            child: _boardTiles(
              screenSize: screenSize,
              nbColumns: nbColumns,
              contentSize: contentSize,
              squareSize: squareSize,
              tileSpacing: tileSpacing,
              xTilt: 0,
              yTilt: 0,
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

      return Center(
        child: Padding(
            padding: EdgeInsets.all(boardSpacing), child: tiltedContent),
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

          var content = SizedBox(
              child: idx == nbColumns * nbColumns - 1
                  ? null
                  : ClipRRect(
                      borderRadius:
                          BorderRadius.circular(contentSize.shortestSide / 50),
                      child: PuzzleTileAnyWidget(
                        tile.value,
                        xTilt: 0,
                        yTilt: 0,
                        canvasRect: canvasRect,
                        tileSize: squareSize,
                        tileSpacing: tileSpacing,
                        percentDepth: 1,
                        percentOpacity: 1,
                        borderRadius:
                            BorderRadius.circular(contentSize.shortestSide / 30),
                        nbTiles: widget.puzzle.getDimension(),
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
                              widget.puzzle.moveTiles(tile, []);
                              // print("tile moved $tile");
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
  }
}
