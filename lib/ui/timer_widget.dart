import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_puzzle/asset_path.dart';
import 'package:slide_puzzle/utils.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimerWidgetState();
  }
}

class TimerWidgetState extends State // with SingleTickerProviderStateMixin
{
  Timer? _timer;

  // Ticker? _ticker;
  Duration _totalTime = const Duration();

  Duration get totalDuration => _totalTime;

  start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick(Duration(seconds: timer.tick));
    });

    // _ticker?.dispose();
    // _ticker = Ticker(_tick);
    // _ticker?.start();
  }

  stop() {
    _timer?.cancel();
    // _ticker?.stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return const SizedBox();
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
