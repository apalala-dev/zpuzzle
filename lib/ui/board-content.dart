import 'package:flutter/cupertino.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/ui/tiles/puzzle-tile-any-widget.dart';

class BoardContent extends StatefulWidget {
  final Size contentSize;
  final Puzzle puzzle;
  final Widget backgroundWidget;

  const BoardContent({
    Key? key,
    required this.contentSize,
    required this.puzzle,
    required this.backgroundWidget,
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
    final tileSpacing = widget.contentSize.shortestSide / 100;
    final squareSize = ((widget.contentSize.shortestSide -
            (nbColumns - 1) * tileSpacing -
            innerBoardSpacing * 2 * 2 -
            58) /
        nbColumns);

    return SizedBox(
      child: Stack(children: [
        ...List.generate(nbColumns * nbColumns, (idx) {
          var tile = widget.puzzle.tiles[idx];

          var content = SizedBox(
              child: idx == nbColumns * nbColumns - 1
                  ? null
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(
                          widget.contentSize.shortestSide / 50),
                      child: PuzzleTileAnyWidget(
                        tile.value,
                        xTilt: 0,
                        yTilt: 0,
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
                            setState(() {
                              widget.puzzle.moveTiles(tile, []);
                            });
                          }
                        },
                      )),
              width: squareSize,
              height: squareSize);

          return AnimatedPositioned(
            child: content,
            duration: const Duration(milliseconds: 400),
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
