import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_puzzle/utils.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimerWidgetState();
  }
}

class TimerWidgetState extends State {
  Timer? _timer;

  Duration _totalTime = const Duration();

  Duration get totalDuration => _totalTime;

  start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick(Duration(seconds: timer.tick));
    });
  }

  stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _totalTime.toDisplayableString(),
      style: GoogleFonts.robotoMono(
          fontSize: min(MediaQuery.of(context).size.shortestSide / 26, 18),
          fontWeight: FontWeight.bold),
    );
  }

  void _tick(Duration elapsed) {
    if (elapsed.inSeconds > _totalTime.inSeconds) {
      setState(() {
        _totalTime = elapsed;
      });
    }
  }
}
