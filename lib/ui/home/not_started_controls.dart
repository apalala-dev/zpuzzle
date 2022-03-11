import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_puzzle/app_colors.dart';
import 'package:slide_puzzle/ui/zpuzzle_title.dart';

import '../settings/background_widget_picker.dart';
import '../settings/size_picker.dart';

class NotStartedControls extends StatelessWidget {
  final Size size;
  final Function(int) onPuzzleSizePicked;
  final Function(Widget) onWidgetPicked;
  final VoidCallback onStart;

  const NotStartedControls({
    Key? key,
    required this.size,
    required this.onPuzzleSizePicked,
    required this.onWidgetPicked,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final space = SizedBox(height: size.height / 40);
    return BackdropFilter(
        filter:  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    child: Container(
      key: const ValueKey(2),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.boardOuterColor(context).withOpacity(0.3)
              : AppColors.boardInnerColor(context).withOpacity(0.3),
          borderRadius: BorderRadius.circular(size.shortestSide / 10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        space,
        const ZPuzzleTitle(
          sizeMultiplier: 3,
          maxSize: 48,
        ),
        space,
        Text(
          AppLocalizations.of(context)!.chooseDifficulty,
          style: TextStyle(fontSize: min(size.shortestSide / 24, 20)),
        ),
        SizedBox(height: size.height / 80),
        SizedBox(
          child: SizePicker(onSizePicked: onPuzzleSizePicked),
          height: size.height / 12,
        ),
        space,
        Text(AppLocalizations.of(context)!.pickABackground,
            style: TextStyle(fontSize: min(size.shortestSide / 24, 20))),
        SizedBox(height: size.height / 80),
        SizedBox(
          child: Padding(
            child: BackgroundWidgetPicker(onBackgroundPicked: onWidgetPicked),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          height: size.shortestSide / 8 ,
          width: (size.width / 8) * 7,
        ),
        space,
        ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64))),
            onPressed: onStart,
            label: Text(AppLocalizations.of(context)!.play)),
        space,
      ]),
    ));
  }
}
