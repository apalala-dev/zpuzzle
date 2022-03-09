import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:slide_puzzle/ui/background/fog_particle.dart';

import '../../app-colors.dart';

// https://flutterawesome.com/a-basic-particle-generator-sample-written-in-flutter/
//
// https://felixblaschke.github.io/sa3_liquid/#/
class Fog extends StatefulWidget {
  final Size contentSize;

  const Fog({
    Key? key,
    required this.contentSize,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FogState();
  }
}

class _FogState extends State<Fog> with SingleTickerProviderStateMixin {
  // late AnimationController _animationController;
  final List<FogParticle> _particles = [];
  late Ticker _ticker;
  final DateTime _startTime = DateTime.now();
  Duration _totalDuration = const Duration();

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick);

    // _animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 10000));
    final canvasRect = Offset.zero & widget.contentSize;
    // _animationController.addListener(() {
    //
    // });
    Random rand = Random();
    final particleStartTime = _startTime.add(Duration(
        milliseconds:
            -(FogParticle.maxParticleDuration.inMilliseconds / 2).round()));
    for (int i = 0; i < 50; i++) {
      _particles.add(
        FogParticle.random(rand, particleStartTime, widget.contentSize),
      );
    }
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // _animationController.repeat(reverse: true);
      _ticker.start();
    });
  }

  void _tick(Duration elapsed) {
    _totalDuration = elapsed;
    final currentTime = _startTime.add(_totalDuration);
    for (var p in _particles) {
      if (p.hasReachedDest(currentTime)) {
        p.recreateElsewhere(widget.contentSize, 200);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    // _animationController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.contentSize.width,
      height: widget.contentSize.height,
      child: CustomPaint(
        painter:
            _FogPainter(context, _particles, _startTime.add(_totalDuration)),
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  final BuildContext context;
  final List<FogParticle> particles;
  final DateTime currentTime;

  _FogPainter(
    this.context,
    this.particles,
    this.currentTime,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black, BlendMode.src);
    for (var p in particles) {
      canvas.drawCircle(
        // p.blobData.path!.shift(p.position(currentTime)),
        p.position(currentTime),
        p.size(currentTime),
        Paint()
          ..color = p.color
          ..blendMode = BlendMode.srcATop
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, size.shortestSide * 0.2),
      );
    }
    canvas.drawColor(
        AppColors.fogColor(context).withOpacity(0.4), BlendMode.srcATop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
