import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/rive/speed_controller.dart';
import 'package:supercharged/supercharged.dart';
import 'package:zwidget/zwidget.dart';

import 'ui/tiles/puzzle-tile-any-widget.dart';

class OldPuzzleBoardWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Offset? mousePosition;
  final ImageProvider imageProvider;
  final double imgSize;
  final double? xPercent;
  final double? yPercent;
  final List<Animation<double>> tileEnterAnimation;
  final List<Animation<double>> tileLetterDepthAnimation;
  final List<Animation<double>> tileLetterFadeAnimation;
  final Animation<double> flipAnimation;
  final bool exiting;
  final Widget? backgroundWidget;

  const OldPuzzleBoardWidget({
    Key? key,
    required this.mousePosition,
    required this.puzzle,
    required this.tileEnterAnimation,
    required this.tileLetterDepthAnimation,
    required this.tileLetterFadeAnimation,
    required this.flipAnimation,
    required this.imageProvider,
    required this.imgSize,
    this.xPercent,
    this.yPercent,
    required this.exiting,
    this.backgroundWidget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleBoardWidgetState();
  }
}

class _PuzzleBoardWidgetState extends State<OldPuzzleBoardWidget> {
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
      // print("layout huilder build");
      var size = Size(constraints.maxWidth, constraints.maxHeight);
      print("cur size: $size");

      // var size = Size(200,200);
      var canvasRect = Offset.zero & size;
      final boardSpacing = size.shortestSide / 100; //20.0;
      final innerBoardSpacing = size.shortestSide / 30; //8.0;

      Widget boardTiles;

      var nbColumns = widget.puzzle.getDimension();
      var tileSpacing = size.shortestSide / 200;
      var squareSize = ((size.shortestSide -
              (nbColumns - 1) * tileSpacing -
              boardSpacing * 2 * 2 -
              innerBoardSpacing * 2 * 2 -
              58) /
          nbColumns);
      // squareSize = 70;

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

      boardTiles = SizedBox(
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
            // if (idx == 0) {
            //   print("exiting: ${widget.exiting}, scale: $scaledTile, yOffset: $yOffset");
            // }
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
                            borderRadius:
                                BorderRadius.circular(size.shortestSide / 50),
                            child: PuzzleTileAnyWidget(
                              tile,
                              xTilt: xTilt,
                              yTilt: yTilt,
                              canvasRect: canvasRect,
                              tileSize: squareSize,
                              tileSpacing: tileSpacing,
                              imageProvider: widget.imageProvider,
                              imgSize: widget.imgSize,
                              percentDepth: percentDepthText,
                              percentOpacity: percentOpacityText,
                              nbTiles: widget.puzzle.getDimension(),
                              borderRadius:
                                  BorderRadius.circular(size.shortestSide / 30),
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
          rotationY: xTilt,
          rotationX: yTilt,
          alignment: Alignment.bottomCenter,
          depth: 0.05 * size.shortestSide,
          direction: ZDirection.backwards,
          layers: 10,
          midToTopChild: Container(
            width: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
            height: squareSize * nbColumns + tileSpacing * (nbColumns - 1),
            padding: EdgeInsets.all(innerBoardSpacing),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
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
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          midChild: Container(
            child: Container(
              child: boardTiles,
              padding: EdgeInsets.all(innerBoardSpacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(innerBoardSpacing),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(xTilt * 0.01 * size.shortestSide,
                          yTilt * 0.01 * size.shortestSide))
                ],
              ),
            ),
            padding: EdgeInsets.all(innerBoardSpacing),
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
                borderRadius: BorderRadius.circular(size.shortestSide / 30)),
          ));

      return Center(
          child: Padding(
              padding: EdgeInsets.all(boardSpacing), child: newContent));
    });
  }
}
