import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/ui/zwidget_wrapper.dart';
import 'package:zwidget/zwidget.dart';

class PuzzleRiveTileWidget extends StatefulWidget {
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
  final RiveAnimationController riveAnimationController;

  const PuzzleRiveTileWidget(
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
    required this.riveAnimationController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleTileWidgetState();
  }
}

class _PuzzleTileWidgetState extends State<PuzzleRiveTileWidget> {
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
      if (true) {
        text = ZWidgetWrapper(
          midChild: Text("${widget.index}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: Colors.white)),
          topChild: Text("${widget.index}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: Colors.white)),
          midToTopChild: Text("${widget.index}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: HexColor("999999"))),
          rotationY: widget.yTilt,
          rotationX: widget.xTilt,
          depth: widget.percentDepth * 10,
          direction: ZDirection.forwards,
          layers: 15,
        );
      } else {
        text = ZWidget(
          midChild: Text("${widget.index}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: Colors.white)),
          midToTopChild: Text("${widget.index}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: HexColor("999999"))),
          rotationY: widget.yTilt,
          rotationX: widget.xTilt,
          depth: widget.percentDepth * 10,
          direction: ZDirection.forwards,
          layers: 15,
        );
      }
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

    // fracOff = FractionalOffset(
    //   (1 - 1) / (3 - 1),
    //   (1 - 1) / (3 - 1),
    // );

    // const AssetImage("assets/img/moon.png")
    Matrix4 mat4 = Matrix4.identity()..translate(widget.tileSize);
    final transformationController = TransformationController()..value = mat4;
    text = SizedBox(
      width: widget.tileSize,
      height: widget.tileSize,
      child: Stack(children: [
        Positioned.fill(
          // child: InteractiveViewer(
          //   transformationController: transformationController,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: fracOff,
              child: SizedBox(
                child: RiveAnimation.asset(
                  'assets/rive/earth.riv',
                  fit: BoxFit.cover,
                  controllers: [widget.riveAnimationController],
                ),
                height: nbTiles * widget.tileSize,
                width: nbTiles * widget.tileSize,
                // ),
              ),
            ),
          ),
        ),
        // Positioned.fill(
        //     child: OverflowBox(
        //         alignment: fracOff,
        //         child: UnconstrainedBox(child:SizedBox(
        //           child: const RiveAnimation.asset(
        //             'assets/rive/earth.riv',
        //             fit: BoxFit.scaleDown,
        //           ),
        //           height: nbTiles * widget.tileSize,
        //           width: nbTiles * widget.tileSize,
        //         )))),
        // Positioned.fill(
        //   child: ClipRect(
        //       child: Align(
        //           child: UnconstrainedBox(
        //             child: SizedBox(
        //               child: const RiveAnimation.asset(
        //                 'assets/rive/earth.riv',
        //                 fit: BoxFit.scaleDown,
        //               ),
        //               height: nbTiles * widget.tileSize,
        //               width: nbTiles * widget.tileSize,
        //             ),
        //           ),
        //           alignment: fracOff)),
        // ),
        Center(child: text),
      ]),
    );

    return Padding(
      child: InkWell(
        child: ZWidgetWrapper(
          rotationY: widget.xTilt,
          rotationX: widget.yTilt,
          depth: 0.01 * widget.canvasRect.shortestSide,
          direction: ZDirection.forwards,
          layers: 20,
          midToTopChild: Container(
            width: widget.tileSize,
            height: widget.tileSize,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(0)),
          ),
          midChild: Center(
            child: text,
          ),
          topChild: Center(
            child: text,
          ),
        ),
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
