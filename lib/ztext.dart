/*!
 * ztext.js v0.0.2
 * https://bennettfeely.com/ztext
 * Licensed MIT | (c) 2020 Bennett Feely
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_color/src/helper.dart';
import 'package:slide_puzzle/z-widget.dart';


class ZText extends StatelessWidget {
  final String text;
  final TextStyle style;
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

  const ZText(
    this.text, {
    this.style = const TextStyle(),
    Key? key,
    this.depth = 1,
    this.direction = ZDirection.both,
    this.eventRotation = 30,
    this.xPercent = 0.3,
    this.yPercent = 0.3,
    this.fade = false,
    this.layers = 4,
    this.perspective = 20,
    this.z = true,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO Try to create a class ZWidget which replicates the principle of ZText
    // but with Container, Image, Icon, etc

    return Stack(
      children: List.generate(
          layers,
          (index) => _ZTextLayer(
                text,
                style: style,
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
              )),
    );
  }
}

class _ZTextLayer extends StatelessWidget {
  final String text;
  final TextStyle style;
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

  const _ZTextLayer(this.text,
      {required this.style,
      required this.layer,
      required this.nbLayers,
      required this.direction,
      required this.reverse,
      required this.depth,
      required this.perspective,
      required this.fade,
      required this.xPercent,
      required this.yPercent,
      required this.rotation});

  @override
  Widget build(BuildContext context) {
    var percent = layer / nbLayers;

    // Shift the layer on the z axis
    double zTranslation;
    int idxToHighlight;
    switch (direction) {
      case ZDirection.both:
        zTranslation = -(percent * depth) + depth / 2;
        idxToHighlight = (nbLayers / 2).round();
        break;
      case ZDirection.backwards:
        zTranslation = -percent * depth;
        idxToHighlight = 0;
        break;
      case ZDirection.forwards:
        zTranslation = -(percent * depth) + depth;
        idxToHighlight = nbLayers - 1;
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

    return Opacity(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(xTilt)
          ..rotateY(yTilt)
          ..translate(0, 0, zTranslation * 25),
        child: Text(
          text,
          style: layer == idxToHighlight
              ? style
              : style.copyWith(color: style.color?.darker(40)),
        ),
      ),
      opacity: fade ? percent / 2 : 1,
    );
  }
}
