import 'package:flutter/material.dart';

class FitOrScaleWidget extends StatelessWidget {
  final double minWidth;
  final double minHeight;
  final Widget child;

  const FitOrScaleWidget({
    Key? key,
    required this.minWidth,
    required this.minHeight,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      if (minWidth < constraints.maxWidth &&
          minHeight < constraints.maxHeight) {
        return child;
      } else {
        final ratioW = constraints.maxWidth / minWidth;
        final ratioH = constraints.maxHeight / minHeight;

        if (ratioW < ratioH) {
          // Scale based on width
          // print(
          //     'minW: $minWidth, maxW: ${constraints.maxWidth}, ratio: ${constraints.maxWidth / minWidth}');
          return Transform.scale(
              child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    child: child,
                    width: minWidth,
                    height: constraints.maxHeight *
                        (minWidth / constraints.maxWidth),
                  )),
              scale: constraints.maxWidth / minWidth);
        } else {
          // Scale based on height
          return Transform.scale(
              child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    child: child,
                    width: constraints.maxWidth *
                        (minHeight / constraints.maxHeight),
                    height: minHeight,
                  )),
              scale: constraints.maxHeight / minHeight);
        }
      }
    });
  }
}
