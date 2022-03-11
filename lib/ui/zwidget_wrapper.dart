import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zwidget/zwidget.dart';

class ZWidgetWrapper extends StatelessWidget {
  final bool debug;
  final double rotationY;
  final double rotationX;
  final Alignment alignment;
  final double perspective;
  final double depth;
  final ZDirection direction;
  final int layers;
  final Widget midChild;
  final Widget topChild;
  final Widget? midToTopChild;
  final Widget? midToBotChild;

  const ZWidgetWrapper({
    Key? key,
    this.debug = false,
    this.rotationY = 0,
    this.rotationX = 0,
    this.alignment = FractionalOffset.center,
    this.perspective = 1,
    required this.depth,
    required this.direction,
    required this.layers,
    required this.midChild,
    required this.topChild,
    this.midToTopChild,
    this.midToBotChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001 * perspective)
          ..rotateX(rotationX)
          ..rotateY(-rotationY),
        child: topChild,
        alignment: alignment,
      );
    } else {
      return ZWidget(
        midChild: midChild,
        topChild: topChild,
        depth: depth,
        direction: direction,
        layers: layers,
        alignment: alignment,
        rotationX: rotationX,
        rotationY: rotationY,
        perspective: perspective,
        midToTopChild: midToTopChild,
        midToBotChild: midToBotChild,
      );
    }
  }
}
