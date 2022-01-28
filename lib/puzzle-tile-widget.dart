import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_color/src/helper.dart';
import 'package:slide_puzzle/z-widget.dart';
import 'package:slide_puzzle/ztext.dart';
import 'package:supercharged/supercharged.dart';

class PuzzleTileWidget extends StatefulWidget {
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

  const PuzzleTileWidget(
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
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleTileWidgetState();
  }
}

class _PuzzleTileWidgetState extends State<PuzzleTileWidget> {
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
        yPercent: widget.yTilt,
        xPercent: widget.xTilt,
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

    // text = widget.image ?? text;

    // var imgSize = 1668.0;
    var scaledDownSize =
        3 * widget.tileSize * MediaQuery.of(context).devicePixelRatio;

    // print(
    //     "($scaledDownSize * ($imgSize / 3)) / $imgSize = ${(scaledDownSize * (imgSize / 3)) / imgSize}");

    var nbTiles = widget.nbTiles;
    FractionalOffset fracOff = FractionalOffset(
        ((widget.index - 1) % nbTiles) * (1 / (nbTiles - 1)),
        ((widget.index - 1) ~/ nbTiles) * (1 / (nbTiles - 1)));

    // const AssetImage("assets/img/moon.png")
    text = Container(
      width: widget.tileSize,
      height: widget.tileSize,
      child: Center(child: text),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: widget.imageProvider,
              fit: BoxFit.none,
              scale: widget.imgSize / (nbTiles * widget.tileSize),
              // scaledDownSize / ((scaledDownSize * (imgSize / 3)) / imgSize),
              alignment: fracOff)),
    );

    // return  InkWell(
    //     child: ZWidget(
    //       child: Container(
    //           child: Center(
    //             child: text,
    //           ),
    //           decoration: BoxDecoration(
    //             color: Colors.teal,
    //             borderRadius: BorderRadius.circular(8),
    //           )),
    //       aboveChild: Container(
    //           child: Center(
    //             child: text,
    //           ),
    //           decoration: BoxDecoration(
    //             color: Colors.teal.darker(30),
    //             borderRadius: BorderRadius.circular(8),
    //           )),
    //       yPercent:-xTilt / (widget.canvasRect.size.width / 2),
    //       xPercent: -yTilt / (widget.canvasRect.size.height / 2),
    //       depth: 0.9,
    //       layers: 1,
    //       direction: ZDirection.forwards,
    //     ),
    //     onTap: widget.onTap,
    //   )
    //   ;

    return Padding(
      child: InkWell(
        child: ZWidget(
            yPercent: widget.xTilt,
            xPercent: widget.yTilt,
            depth: 0.01 * widget.canvasRect.shortestSide,
            direction: ZDirection.forwards,
            layers: 20,
            eventRotation: 0,
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

    return Padding(
      child: InkWell(
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
                    offset: Offset(widget.xTilt * 2, widget.yTilt * 2))
              ]),
        ),
        onTap: widget.onTap,
      ),
      padding: EdgeInsets.all(widget.tileSpacing),
    );
  }
}
