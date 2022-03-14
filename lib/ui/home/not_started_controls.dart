import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zpuzzle/app_colors.dart';
import 'package:zpuzzle/asset_path.dart';
import 'package:zpuzzle/ui/board_content.dart';
import 'package:zpuzzle/ui/settings/widget_picker_dialog.dart';
import 'package:zpuzzle/ui/zpuzzle_title.dart';

import '../../model/puzzle.dart';
import '../settings/background_widget_picker.dart';
import '../settings/puzzle_size_picker.dart';

class NotStartedControls extends StatelessWidget {
  final Size size;
  final Widget selectedWidget;
  final int puzzleSize;
  final Function(int) onPuzzleSizePicked;
  final Function(Widget) onWidgetPicked;
  final VoidCallback onStart;

  const NotStartedControls({
    Key? key,
    required this.size,
    required this.puzzleSize,
    required this.onPuzzleSizePicked,
    required this.onWidgetPicked,
    required this.onStart,
    required this.selectedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final space = SizedBox(height: size.height / 40);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 50),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            key: const ValueKey(2),
            height: MediaQuery.of(context).size.height / 1.5,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.boardOuterColor(context).withOpacity(0.3)
                    : Colors.white54,
                borderRadius: BorderRadius.circular(size.shortestSide / 10)),
            child: Column(children: [
              space,
              const ZPuzzleTitle(
                sizeMultiplier: 3,
                maxSize: 48,
              ),
              Padding(
                child: Text(
                  AppLocalizations.of(context)!.chooseDifficultyAndBackground,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: min(size.shortestSide / 24, 20)),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: size.height / 80, horizontal: 8),
              ),
              Expanded(
                  child: Padding(
                child: (size.width > size.height)
                    ? Row(children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: PuzzleSizePicker(
                            onSizePicked: onPuzzleSizePicked,
                            baseSize: puzzleSize,
                            horizontal: false,
                          ),
                        ),
                        SizedBox(
                          width: size.width / 100,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white12),
                            child: Row(children: [
                              Flexible(
                                  child: Column(children: [
                                SizedBox(height: size.shortestSide / 50),
                                Text(AppLocalizations.of(context)!.background,
                                    style: TextStyle(
                                        fontSize:
                                            min(size.shortestSide / 28, 24))),
                                Expanded(child: _selectedWidget(context))
                              ])),
                              Flexible(
                                  child: BackgroundWidgetPicker(
                                crossAxisCount: 2,
                                baseWidget: const Image(
                                    key: ValueKey('img05'),
                                    image: AssetImage(AssetPath.img05),
                                    fit: BoxFit.cover),
                                currentlySelectedWidget: selectedWidget,
                                onBackgroundPicked: onWidgetPicked,
                              )),
                            ]),
                          ),
                        )
                      ])
                    : Column(children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: size.width / 1.6,
                              maxHeight: size.height / 10),
                          child: PuzzleSizePicker(
                            onSizePicked: onPuzzleSizePicked,
                            baseSize: puzzleSize,
                            horizontal: true,
                          ),
                        ),
                        SizedBox(
                          height: size.height / 100,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    size.shortestSide / 40),
                                color: Colors.white12),
                            child: Row(children: [
                              Flexible(
                                  child: Column(children: [
                                SizedBox(height: size.shortestSide / 50),
                                Text(AppLocalizations.of(context)!.background,
                                    style: TextStyle(
                                        fontSize:
                                            min(size.shortestSide / 16, 24))),
                                Flexible(child: _selectedWidget(context)),
                              ])),
                              Flexible(
                                  child: BackgroundWidgetPicker(
                                crossAxisCount: 2,
                                baseWidget: const Image(
                                    key: ValueKey('img05'),
                                    image: AssetImage(AssetPath.img05),
                                    fit: BoxFit.cover),
                                currentlySelectedWidget: selectedWidget,
                                onBackgroundPicked: onWidgetPicked,
                              )),
                            ]),
                          ),
                        )
                      ]),
                padding: EdgeInsets.symmetric(horizontal: size.width / 80),
              )),
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
          )),
    );
  }

  Widget _selectedWidget(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Center(
          child: SizedBox(
        width: min(constraints.maxWidth, constraints.maxHeight),
        height: min(constraints.maxWidth, constraints.maxHeight),
        child: Padding(
          child: Stack(children: [
            AbsorbPointer(
              child: BoardContent(
                  showIndicator: false,
                  contentSize: Size(
                      min(constraints.maxWidth, constraints.maxHeight),
                      min(constraints.maxWidth, constraints.maxHeight)),
                  puzzle: Puzzle.generate(puzzleSize, shuffle: false),
                  backgroundWidget: selectedWidget,
                  onTileMoved: (_) {},
                  xTilt: 0,
                  yTilt: 0),
              absorbing: true,
            ),
            Positioned.fill(
                child: Align(
              child: Padding(
                child: FloatingActionButton.small(
                  onPressed: () => WidgetPickerDialog.show(
                      context, selectedWidget, (w) => onWidgetPicked(w)),
                  child: const Icon(Icons.edit),
                ),
                padding: EdgeInsets.only(
                    bottom: size.shortestSide / 100,
                    right: size.shortestSide / 100),
              ),
              alignment: Alignment.bottomRight,
            ))
          ]),
          padding: EdgeInsets.all(
              min(constraints.maxWidth, constraints.maxHeight) / 15),
        ),
      ));
    });
  }
}
