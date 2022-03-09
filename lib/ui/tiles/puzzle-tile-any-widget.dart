import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_color/src/helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_puzzle/asset-path.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/tiles/maybe-show-indicator.dart';
import 'package:zwidget/zwidget.dart';

class PuzzleTileAnyWidget extends StatefulWidget {
  final Rect canvasRect;
  final Tile tile;
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
  final bool showIndicator;

  const PuzzleTileAnyWidget(
    this.tile, {
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
    this.showIndicator = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleTileWidgetState();
  }
}

class _PuzzleTileWidgetState extends State<PuzzleTileAnyWidget> {
  bool _changedState = false;

  @override
  void didUpdateWidget(covariant PuzzleTileAnyWidget oldWidget) {
    _changedState = oldWidget.showIndicator != widget.showIndicator;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var nbTiles = widget.nbTiles;
    FractionalOffset fracOff = FractionalOffset(
        ((widget.tile.value - 1) % nbTiles) * (1 / (nbTiles - 1)),
        ((widget.tile.value - 1) ~/ nbTiles) * (1 / (nbTiles - 1)));

    Widget text = _text();
    // final indicator = SvgPicture.asset(
    //   AssetPath.slideIndicator,
    //   width: widget.tileSize / 4,
    //   height: widget.tileSize / 4,
    //   color: Colors.amber,
    // );
    // text = MaybeShowIndicator(
    //   tile: widget.tile,
    //   child: Stack(children: [
    //     ImageFiltered(
    //         imageFilter: ImageFilter.blur(
    //             sigmaY: 2, sigmaX: 2, tileMode: TileMode.decal),
    //         child: ColorFiltered(
    //             colorFilter:
    //                 const ColorFilter.mode(Colors.black, BlendMode.srcATop),
    //             child: indicator)),
    //     indicator
    //   ]),
    //   tileSize: widget.tileSize,
    // );
    // return Container(
    //     child: Center(child: text),
    //     decoration: BoxDecoration(
    //         color: Colors.pink, borderRadius: BorderRadius.circular(48)),
    //     width: widget.tileSize,
    //     height: widget.tileSize);
    // Using png instead of svg make the perpective work again
    // Quand on met un container l'effet de profondeur marche, quand on met l'indicator ça marche pas
    text = MaybeShowIndicator(
      tile: widget.tile,
      child: Center(
        child: Image.asset(
          AssetPath.slideIndicatorWithShadow,
          width: widget.tileSize / 4,
          height: widget.tileSize / 4,
        ),
      ),
      tileSize: widget.tileSize,
      showIndicator: widget.showIndicator,
      changedState: _changedState,
    );
    final Widget content;
    if (false && widget.child is Image) {
      content = Container(
        width: widget.tileSize,
        height: widget.tileSize,
        child: Center(child: text),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: (widget.child as Image).image,
                fit: BoxFit.none,
                // scaledDownSize / ((scaledDownSize * (imgSize / 3)) / imgSize),
                alignment: fracOff)),
      );
    } else {
      content = SizedBox(
        width: widget.tileSize,
        height: widget.tileSize,
        // color: Colors.pink,
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
    }

    final result = Padding(
      child: InkWell(
        child: true
            ? content
            : ZWidget(
                rotationY: 0,
                //,widget.xTilt,
                rotationX: 0,
                //widget.yTilt,
                depth: 50,
                // 0.05 * widget.canvasRect.shortestSide,
                direction: ZDirection.forwards,
                layers: 5,
                perspective: 0.5,
                alignment: Alignment.center,
                midChild: Container(
                  width: widget.tileSize,
                  height: widget.tileSize,
                  decoration: BoxDecoration(
                      color: Colors.black, borderRadius: widget.borderRadius),
                ),
                midToTopChild: Container(
                  width: widget.tileSize,
                  height: widget.tileSize,
                  decoration: BoxDecoration(
                      color: Colors.pink, borderRadius: widget.borderRadius),
                ),
                topChild: Center(
                  child: content,
                ),
              ),
        onTap: widget.onTap,
      ),
      padding: EdgeInsets.all(widget.tileSpacing),
    );

    if (widget.xTilt == 0 && widget.yTilt == 0) {
      return result; // Not sure if this RepaintBoundary is very useful
      return RepaintBoundary(
        child: result,
      );
    } else {
      return result;
    }
  }

  Widget _text() {
    if (kIsWeb) {
      return const SizedBox();
    }
    Widget text = Text(
      "${widget.tile.value}",
      style: TextStyle(fontSize: 54, color: Colors.white, shadows: [
        Shadow(
          color: Colors.teal.darker(50),
          offset: Offset(widget.xTilt, widget.yTilt),
        )
      ]),
    );

    if (widget.percentDepth > 0) {
      if (true) {
        text = ZWidget(
          midChild: Text("${widget.tile.value}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: HexColor("999999"))),
          topChild: Text("${widget.tile.value}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: Colors.white)),
          rotationY: widget.yTilt,
          rotationX: widget.xTilt,
          depth: widget.percentDepth * 20,
          direction: ZDirection.forwards,
          layers: 5,
        );
        text = Text("${widget.tile.value}",
            style: TextStyle(
              fontSize: widget.tileSize / 2,
              color: Colors.black.withOpacity(0.25),
            ));
      } else {
        text = ZWidget(
          midChild: Text("${widget.tile.value}",
              style: TextStyle(
                  fontSize: widget.tileSize / 1.5, color: Colors.white)),
          midToTopChild: Text("${widget.tile.value}",
              style: TextStyle(
                  fontSize: widget.tileSize / 1.5, color: HexColor("999999"))),
          topChild: Text("${widget.tile.value}",
              style: TextStyle(
                  fontSize: widget.tileSize / 2, color: Colors.white)),
          rotationY: widget.yTilt,
          rotationX: widget.xTilt,
          depth: widget.percentDepth * 10,
          direction: ZDirection.backwards,
          layers: 10,
        );
      }
    } else {
      text = Text(
        "${widget.tile.value}",
        style: TextStyle(
          fontSize: widget.tileSize / 1.5,
          color: Colors.white.withOpacity(widget.percentOpacity),
        ),
      );
    }
    return text;
  }
}
