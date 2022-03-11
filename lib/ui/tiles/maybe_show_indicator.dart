import 'package:flutter/cupertino.dart';

import '../../model/tile.dart';

class MaybeShowIndicator extends StatelessWidget {
  final Tile tile;
  final Widget child;
  final double tileSize;
  final bool showIndicator;
  final bool changedState;

  const MaybeShowIndicator({
    Key? key,
    required this.tile,
    required this.child,
    required this.tileSize,
    this.showIndicator = true,
    this.changedState = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const empty = SizedBox();

    if (tile.hasMoved()) {
      if (tile.currentPosition == tile.correctPosition ||
          tile.previousPosition == tile.correctPosition) {
        return TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: tile.currentPosition == tile.correctPosition
                    ? (showIndicator ? 1.0 : 0.0)
                    : 0.0,
                end: tile.currentPosition == tile.correctPosition
                    ? 0.0
                    : (showIndicator ? 1.0 : 0.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: child,
            builder: (context, scale, child) {
              return Transform.scale(
                child: Transform.rotate(
                  child: child!,
                  angle: tile.currentPosition == tile.correctPosition
                      ? tile.previousIndicatorAngle
                      : tile.currentIndicatorAngle,
                ),
                scale: scale,
              );
            });
      }

      return _showIfItShould(
        TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: tile.previousIndicatorAngle,
                end: tile.currentIndicatorAngle),
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            child: child,
            builder: (context, rotation, child) {
              return Transform.rotate(
                child: child!,
                angle: rotation,
              );
            }),
      );
    } else {
      if (tile.currentPosition == tile.correctPosition) {
        return empty;
      } else {
        final result = Transform.rotate(
          child: child,
          angle: tile.currentIndicatorAngle,
        );
        return _showIfItShould(result);
      }
    }
  }

  Widget _showIfItShould(Widget result) {
    if (changedState) {
      return TweenAnimationBuilder<double>(
          tween: Tween<double>(
              begin: showIndicator ? 0.0 : 1.0, end: showIndicator ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: child,
          builder: (context, scale, child) {
            return Transform.scale(child: result, scale: scale);
          });
    }
    return showIndicator ? result : const SizedBox();
  }
}
