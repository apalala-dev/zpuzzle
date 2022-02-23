import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_color/src/helper.dart';
import 'package:zwidget/zwidget.dart';

class PuzzleTileAnyWidget extends StatefulWidget {
  final Rect canvasRect;
  final int index;
  final VoidCallback onTap;
  final double tileSize;
  final double tileSpacing;
  final double xTilt;
  final double yTilt;
  final double percentDepth;
  final double percentOpacity;
  final int nbTiles;
  final ImageProvider? imageProvider;
  final double? imgSize;
  final Widget child;
  final BorderRadius borderRadius;

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
    this.imageProvider,
    this.imgSize,
    this.percentDepth = 1,
    this.percentOpacity = 1,
    required this.child,
    required this.borderRadius,
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
            style: TextStyle(
                fontSize: widget.tileSize / 1.5, color: Colors.white)),
        belowChild: Text("${widget.index}",
            style: TextStyle(
                fontSize: widget.tileSize / 1.5, color: HexColor("999999"))),
        rotationY: widget.yTilt,
        rotationX: widget.xTilt,
        depth: widget.percentDepth * 10,
        direction: ZDirection.backwards,
        layers: 10,
      );
    } else {
      text = Text(
        "${widget.index}",
        style: TextStyle(
          fontSize: widget.tileSize / 1.5,
          color: Colors.white.withOpacity(widget.percentOpacity),
        ),
      );
    }

    var nbTiles = widget.nbTiles;
    FractionalOffset fracOff = FractionalOffset(
        ((widget.index - 1) % nbTiles) * (1 / (nbTiles - 1)),
        ((widget.index - 1) ~/ nbTiles) * (1 / (nbTiles - 1)));

    final content = SizedBox(
      width: widget.tileSize,
      height: widget.tileSize,
      child: Stack(children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: widget.borderRadius,
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
            rotationY: -widget.xTilt,
            rotationX: -widget.yTilt,
            depth: 1,
            // 0.05 * widget.canvasRect.shortestSide,
            direction: ZDirection.backwards,
            layers: 10,
            alignment: Alignment.bottomCenter,
            belowChild: Container(
              width: widget.tileSize,
              height: widget.tileSize,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: widget.borderRadius),
            ),
            child: Center(
              child: content,
            )),
        onTap: widget.onTap,
      ),
      padding: EdgeInsets.all(widget.tileSpacing),
    );
  }
}
