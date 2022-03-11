import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/asset_path.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/tiles/maybe_show_indicator.dart';

import '../../app_colors.dart';

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

    Widget indicator = MaybeShowIndicator(
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
    final Widget content = Container(
      width: widget.tileSize,
      height: widget.tileSize,
      decoration: kIsWeb
          ? BoxDecoration(borderRadius: widget.borderRadius, boxShadow: [
              BoxShadow(
                  color: AppColors.perspectiveColor,
                  spreadRadius: widget.tileSize / 100,
                  offset: Offset(
                      -(widget.xTilt < 0
                          ? max(widget.xTilt * 0.05 * widget.tileSize,
                              -widget.tileSize / 30)
                          : min(widget.xTilt * 0.05 * widget.tileSize,
                              widget.tileSize / 30)),
                      -(widget.yTilt < 0
                          ? max(widget.yTilt * 0.05 * widget.tileSize,
                              -widget.tileSize / 30)
                          : min(widget.yTilt * 0.05 * widget.tileSize,
                              widget.tileSize / 30))))
            ])
          : null,
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
        Center(child: indicator),
      ]),
    );

    final result = Padding(
      child: InkWell(
        child: content,
        onTap: widget.onTap,
      ),
      padding: EdgeInsets.all(widget.tileSpacing),
    );

    return result;
  }
}
