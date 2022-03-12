import 'package:flutter/material.dart';

import '../../model/tile.dart';

class MaybeMoveTransition extends StatelessWidget {
  final Tile tile;
  final Widget child;
  final double tileSize;
  final VoidCallback onAnimationEnd;

  const MaybeMoveTransition({
    Key? key,
    required this.tile,
    required this.child,
    required this.tileSize,
    required this.onAnimationEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tile.hasMoved()) {
      return TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(
              begin: Offset(tile.previousPosition.x.toDouble(),
                  tile.previousPosition.y.toDouble()),
              end: Offset(tile.currentPosition.x.toDouble(),
                  tile.currentPosition.y.toDouble())),
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          child: child,
          onEnd: onAnimationEnd,
          builder: (context, offset, child) {
            return Positioned(
                child: child!,
                left: tileSize * (offset.dx - 1),
                top: tileSize * (offset.dy - 1));
          });
    } else {
      return Positioned(
        child: child,
        left: tileSize * (tile.currentPosition.x - 1),
        top: tileSize * (tile.currentPosition.y - 1),
      );
    }
  }
}
