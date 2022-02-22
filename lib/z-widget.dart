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

// TODO The Opacity widget is bad for performances and is buggy (it makes things appear at a different place on android than on web)
class ZWidget extends StatelessWidget {
  final Widget child;
  final Widget? belowChild;
  final Widget? aboveChild;
  final double depth;
  final ZDirection direction;

  final double rotationX;
  final double rotationY;

  // final ZDirection eventDirection;
  final bool fade;
  final int layers;
  final bool z;
  final bool reverse;
  final bool debug;

  final int perspective;
  final Alignment? alignment;

  const ZWidget(
      {required this.child,
      this.belowChild,
      this.aboveChild,
      Key? key,
      this.depth = 1,
      this.direction = ZDirection.both,
      this.rotationX = 0,
      this.rotationY = 0,
      this.fade = false,
      this.layers = 4,
      this.z = true,
      this.reverse = false,
      this.debug = false,
      this.alignment,
      this.perspective = 5})
      : super(key: key);

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
                fade: fade,
                xPercent: rotationX,
                yPercent: rotationY,
                reverse: false,
                debug: debug,
                alignment: alignment,
                perspective: perspective,
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
  final ZDirection direction;
  final bool reverse;
  final bool fade;
  final double xPercent;
  final double yPercent;
  final bool debug;
  final Alignment? alignment;
  final int perspective;

  const _ZWidgetLayer(
    this.child, {
    required this.belowChild,
    required this.aboveChild,
    required this.layer,
    required this.nbLayers,
    required this.direction,
    required this.reverse,
    required this.depth,
    required this.fade,
    required this.xPercent,
    required this.yPercent,
    this.debug = false,
    required this.alignment,
    required this.perspective,
  });

  @override
  Widget build(BuildContext context) {
    var percent = layer / nbLayers;

    // Shift the layer on the z axis

    Widget layerChild;
    double zTranslation;
    switch (direction) {
      case ZDirection.both:
        zTranslation = -(percent * depth) + depth / 2;
        final midLayer = (nbLayers / 2).round();
        layerChild = layer == midLayer
            ? child
            : layer < midLayer
                ? belowChild
                : aboveChild;
        // layerChild = layer == nbLayers - 1
        //     ? child
        //     : layer < nbLayers / 2
        //         ? belowChild
        //         : aboveChild;
        break;
      case ZDirection.backwards:
        zTranslation = -(percent * depth) + depth;
        layerChild = layer == nbLayers - 1 ? child : belowChild;
        break;
      case ZDirection.forwards:
        zTranslation = -percent * depth;
        layerChild = layer == 0 ? child : aboveChild;
        break;
    }

    // Switch neg/pos values if eventDirection is reversed
    double eventDirectionAdj;
    if (reverse) {
      eventDirectionAdj = -1;
    } else {
      eventDirectionAdj = 1;
    }

    // Multiply percent rotation by eventRotation and eventDirection
    var xTilt = xPercent * eventDirectionAdj;
    var yTilt = -yPercent * eventDirectionAdj;

    // Keep values in bounds [-1, 1] // TODO Not used in ztext.js
    // var xClamped = min(max(xTilt, -1), 1);
    // var yClamped = min(max(yTilt, -1), 1);

    // var transform =
    //     "rotateX(" + y_tilt ") rotateY(" + x_tilt ")";
    // Transform.scale(
    //     scale: (zTranslation + perspective) / perspective,
    //     child:

    // print("tilt: $xTilt, $yTilt");
    // if (debug) {
    //   print(
    //       "layer $layer/$nbLayers xTilt: ${xTilt / pi}, yTilt: $yTilt, zTranslation: $zTranslation");
    // }

    if (!fade) {
      final content = Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001 * perspective)
          ..rotateX(xTilt)
          ..rotateY(yTilt)
          ..translate(0.0, 0.0, zTranslation),
        child: layerChild,
        alignment: alignment ?? FractionalOffset.center,
      );
      if (debug) {
        return Container(
          child: content,
          decoration:
              BoxDecoration(border: Border.all(width: 2, color: Colors.pink)),
        );
      } else {
        return content;
      }
    }

    return Opacity(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(xTilt)
          ..rotateY(yTilt)
          ..translate(0.0, 0.0, zTranslation),
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
