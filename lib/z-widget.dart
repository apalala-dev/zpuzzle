/*!
 * ztext.js v0.0.2
 * https://bennettfeely.com/ztext
 * Licensed MIT | (c) 2020 Bennett Feely
 */

import 'dart:math';

import 'package:flutter/material.dart';

enum ZDirection {
  both,
  backwards,
  forwards,
}

zMatrix4() {
  // TODO Implement this method, with all args needed to replace layers business logic
  // This way, we could apply this matrix4 to anything: a widget, a canvas or a path (other things might apply)
}

class ZWidget extends StatelessWidget {
  final Widget child;
  final Widget? belowChild;
  final Widget? aboveChild;
  final double depth;
  final ZDirection direction;

  // event: "none",
  final double eventRotation;
  final double xPercent;
  final double yPercent;

  // final ZDirection eventDirection;
  final bool fade;
  final int layers;
  final int perspective;
  final bool z;
  final bool reverse;
  final bool debug;

  const ZWidget({
    required this.child,
    this.belowChild,
    this.aboveChild,
    Key? key,
    this.depth = 1,
    this.direction = ZDirection.both,
    this.eventRotation = 0,
    this.xPercent = 0,
    this.yPercent = 0,
    this.fade = false,
    this.layers = 4,
    this.perspective = 20,
    this.z = true,
    this.reverse = false,
    this.debug = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
          layers,
          (index) => _ZWidgetLayer(
                child,
                belowChild: belowChild ?? child,
                aboveChild: aboveChild ?? child,
                layer: index,
                nbLayers: layers,
                direction: direction,
                depth: depth,
                perspective: perspective,
                fade: fade,
                rotation: eventRotation,
                xPercent: xPercent,
                yPercent: yPercent,
                reverse: false,
                debug: debug,
              )),
    );
  }
}

// see https://pub.dev/packages/zflutter for an other way of doing it
class _ZWidgetLayer extends StatelessWidget {
  final Widget child;
  final Widget belowChild;
  final Widget aboveChild;
  final int layer;
  final int nbLayers;
  final double depth;
  final int perspective;
  final ZDirection direction;
  final bool reverse;
  final bool fade;
  final double xPercent;
  final double yPercent;
  final double rotation;
  final bool debug;

  const _ZWidgetLayer(
    this.child, {
    required this.belowChild,
    required this.aboveChild,
    required this.layer,
    required this.nbLayers,
    required this.direction,
    required this.reverse,
    required this.depth,
    required this.perspective,
    required this.fade,
    required this.xPercent,
    required this.yPercent,
    required this.rotation,
    this.debug = false,
  });

  @override
  Widget build(BuildContext context) {
    var percent = layer / nbLayers;

    // Shift the layer on the z axis

    Widget layerChild;
    double zTranslation;
    int idxToHighlight;
    switch (direction) {
      case ZDirection.both:
        zTranslation = -(percent * depth) + depth / 2;
        idxToHighlight = nbLayers - 1;
        layerChild = layer == nbLayers - 1
            ? child
            : layer < nbLayers / 2
                ? belowChild
                : aboveChild;
        break;
      case ZDirection.backwards:
        zTranslation = -(percent * depth) + depth;
        idxToHighlight = 0;
        layerChild = layer == nbLayers - 1 ? child : belowChild;
        break;
      case ZDirection.forwards:
        zTranslation = -percent * depth;
        idxToHighlight = nbLayers - 1;
        layerChild = layer == nbLayers - 1 ? child : aboveChild;
        break;
    }

    // Switch neg/pos values if eventDirection is reversed
    double eventDirectionAdj;
    if (reverse) {
      eventDirectionAdj = -0.1;
    } else {
      eventDirectionAdj = 0.1;
    }

    // Multiply percent rotation by eventRotation and eventDirection
    var xTilt = xPercent * rotation * eventDirectionAdj;
    var yTilt = -yPercent * rotation * eventDirectionAdj;

    // Keep values in bounds [-1, 1] // TODO Not used in ztext.js
    // var xClamped = min(max(xTilt, -1), 1);
    // var yClamped = min(max(yTilt, -1), 1);

    // var transform =
    //     "rotateX(" + y_tilt ") rotateY(" + x_tilt ")";
    // Transform.scale(
    //     scale: (zTranslation + perspective) / perspective,
    //     child:

    // print("tilt: $xTilt, $yTilt");
    if (debug) {
      print("xTilt: ${xTilt/pi}, yTilt: $yTilt, zTranslation: $zTranslation");
    }


    return Opacity(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(xTilt)
          ..rotateY(yTilt)
          ..translate(0, 0, zTranslation),
        child: layerChild,
        alignment: FractionalOffset.center,
      ),
      opacity: fade ? percent / 2 : 1,
    );

    return Opacity(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(xTilt)
          ..rotateY(yTilt)
          ..translate(0, 0, zTranslation),
        child: layerChild,
      ),
      opacity: fade ? percent / 2 : 1,
    );
  }
}
