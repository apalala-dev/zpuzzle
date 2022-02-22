import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_color/src/helper.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/z-widget.dart';
import 'package:slide_puzzle/ztext.dart';
import 'package:supercharged/supercharged.dart';

class PuzzleTileAnyWidget extends StatefulWidget {
  final Rect canvasRect;
  final int index;
  final VoidCallback onTap;
  final double tileSize;
  final double tileSpacing;
  final ImageProvider imageProvider;
  final double xTilt;
  final double yTilt;
  final double percentDepth;
  final double percentOpacity;
  final int nbTiles;
  final double imgSize;
  final Widget child;

  const PuzzleTileAnyWidget(
    this.index, {
    Key? key,
    required this.canvasRect,
    required this.onTap,
    required this.tileSize,
    required this.tileSpacing,
    required this.xTilt,
    required this.yTilt,
    required this.nbTiles,
    required this.imageProvider,
    required this.imgSize,
    this.percentDepth = 1,
    this.percentOpacity = 1,
    required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleTileWidgetState();
  }
}

class _PuzzleTileWidgetState extends State<PuzzleTileAnyWidget> {
  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      "${widget.index}",
      style: TextStyle(fontSize: 54, color: Colors.white, shadows: [
        Shadow(
          color: Colors.teal.darker(50),
          offset: Offset(widget.xTilt, widget.yTilt),
        )
      ]),
    );

    if (widget.percentDepth > 0) {
      text = ZWidget(
        child: Text("${widget.index}",
            style:
                TextStyle(fontSize: widget.tileSize / 2, color: Colors.white)),
        aboveChild: Text("${widget.index}",
            style: TextStyle(
                fontSize: widget.tileSize / 2, color: HexColor("999999"))),
        rotationY: widget.yTilt,
        rotationX: widget.xTilt,
        depth: widget.percentDepth * 10,
        direction: ZDirection.forwards,
        layers: 15,
      );
    } else {
      text = Text(
        "${widget.index}",
        style: TextStyle(
          fontSize: widget.tileSize / 2,
          color: Colors.white.withOpacity(widget.percentOpacity),
        ),
      );
    }

    var nbTiles = widget.nbTiles;
    FractionalOffset fracOff = FractionalOffset(
        ((widget.index - 1) % nbTiles) * (1 / (nbTiles - 1)),
        ((widget.index - 1) ~/ nbTiles) * (1 / (nbTiles - 1)));

    text = SizedBox(
      width: widget.tileSize,
      height: widget.tileSize,
      child: Stack(children: [
        Positioned.fill(
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: fracOff,
              child: SizedBox(
                child: widget.child,
                height: nbTiles * widget.tileSize,
                width: nbTiles * widget.tileSize,
              ),
            ),
          ),
        ),
        Center(child: text),
      ]),
    );

    return Padding(
      child: InkWell(
        child: ZWidget(
            rotationY: widget.xTilt,
            rotationX: widget.yTilt,
            depth: 0.01 * widget.canvasRect.shortestSide,
            direction: ZDirection.forwards,
            layers: 20,
            aboveChild: Container(
              width: widget.tileSize,
              height: widget.tileSize,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(0)),
            ),
            child: Center(
              child: text,
            )),
        onTap: widget.onTap,
      ),
      padding: EdgeInsets.all(widget.tileSpacing),
    );
  }
}
