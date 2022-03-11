import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_puzzle/ui/timer_widget.dart';

import '../../app_colors.dart';
import '../../model/puzzle.dart';
import '../settings/background_widget_picker.dart';
import '../zpuzzle_title.dart';

class StartedControls extends StatelessWidget {
  final Puzzle puzzle;
  final Size size;
  final Widget? selectedWidget;
  final bool solving;
  final bool showIndicator;
  final VoidCallback giveUp;
  final VoidCallback solve;
  final VoidCallback showIndicatorChanged;
  final VoidCallback stoppedSolving;
  final Function(Widget) onWidgetPicked;
  final bool gyroEnabled;
  final VoidCallback gyroChanged;
  final GlobalKey? timerKey;
  final bool isBuildForPerspective;

  const StartedControls({
    Key? key,
    required this.puzzle,
    required this.size,
    required this.selectedWidget,
    required this.showIndicator,
    required this.solving,
    required this.showIndicatorChanged,
    required this.onWidgetPicked,
    required this.timerKey,
    required this.giveUp,
    required this.solve,
    required this.stoppedSolving,
    required this.gyroEnabled,
    required this.gyroChanged,
    this.isBuildForPerspective = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // if (kIsWeb) {
    //   return _solveButton(context, screenSize);
    // }
    final timer = TimerWidget(
      key: timerKey,
    );

    if (size.height == size.shortestSide) {
      return Padding(
        padding: isBuildForPerspective
            ? EdgeInsets.zero
            : EdgeInsets.only(right: size.width / 50),
        child: Container(
          key: const ValueKey(1),
          padding: EdgeInsets.symmetric(
              horizontal: size.shortestSide / 40,
              vertical: size.shortestSide / 100),
          // height: min(max(size.shortestSide / 2, 220), 350),
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.boardOuterColor(context)
                  : AppColors.boardInnerColor(context),
              borderRadius: BorderRadius.circular(size.shortestSide / 40)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ZPuzzleTitle(),
                      Material(
                        child: IconButton(
                          // iconSize: 36,
                          color: Colors.white,
                          onPressed: gyroChanged,
                          icon: Icon(
                            gyroEnabled
                                ? Icons.screen_rotation
                                : Icons.screen_lock_rotation,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        color: Colors.transparent,
                      )
                    ]),
                SizedBox(
                  child: _renderSelectedWidget(context),
                  height: size.shortestSide / 8,
                ),
                Column(children: [
                  _toggle(context, screenSize),
                  _solveButton(context, screenSize),
                ]),
                const SizedBox(
                  height: 8,
                ),
                Wrap(spacing: size.width / 40, children: [
                  _counter(context, screenSize),
                  timer,
                ]),
                _separator(context),
                _giveUpButton(context, screenSize),
              ]),
        ),
      );
    } else {
      return Container(
        key: const ValueKey(1),
        padding: EdgeInsets.symmetric(
            horizontal: size.shortestSide / 40,
            vertical: size.shortestSide / 100),
        height: max(size.height / 3.2, 180),
        width: max(size.shortestSide * 0.8, 260),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.boardOuterColor(context)
                : AppColors.boardInnerColor(context),
            borderRadius: BorderRadius.circular(size.shortestSide / 40)),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Flexible(
            // height: size.height / 6,
            child: Row(children: [
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const ZPuzzleTitle(
                              sizeMultiplier: 1.4,
                            ),
                            Material(
                              child: IconButton(
                                // iconSize: 36,
                                color: Colors.white,
                                onPressed: gyroChanged,
                                icon: Icon(
                                  gyroEnabled
                                      ? Icons.screen_rotation
                                      : Icons.screen_lock_rotation,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                              color: Colors.transparent,
                            )
                          ]),
                      _toggle(context, screenSize),
                      _solveButton(context, screenSize),
                    ],
                  ),
                  flex: 6),
              Expanded(child: _renderSelectedWidget(context), flex: 3),
            ]),
          ),
          Padding(
            child: _separator(context),
            padding: const EdgeInsets.only(top: 4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _giveUpButton(context, screenSize),
            _counter(context, screenSize),
            timer,
          ]),
        ]),
      );
    }
  }

  void _showWidgetPickerDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext ctx, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(AppLocalizations.of(context)!.pickNewBackground),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 2,
              child: BackgroundWidgetPicker(
                  currentlySelectedWidget: selectedWidget,
                  onBackgroundPicked: (sw) {
                    // setState(() {
                    //   _selectedWidget = selectedWidget;
                    // });
                    Navigator.pop(context, sw);
                  }),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ]),
        );
      },
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
            child: child, scale: Curves.easeOutBack.transform(a1.value));
      },
    ).then((newWidget) {
      if (newWidget != null && newWidget is Widget) {
        onWidgetPicked(newWidget);
      }
    });
  }

  Widget _counter(BuildContext context, Size screenSize) {
    return Text.rich(TextSpan(
        children: [
          TextSpan(
              text: "${puzzle.history.length}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
              text: AppLocalizations.of(context)!
                  .nbMovesSuffix(puzzle.history.length)),
        ],
        style: GoogleFonts.robotoMono(
            fontSize: min(screenSize.shortestSide / 26, 18),
            color: Theme.of(context).textTheme.titleLarge?.color)));
  }

  Widget _giveUpButton(BuildContext context, Size screenSize) {
    return TextButton.icon(
      style: TextButton.styleFrom(primary: Colors.red),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext ctx, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.giveUpQuestion)
                  ]),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.no),
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.yes),
                  onPressed: () {
                    Navigator.pop(ctx);
                    giveUp();
                  },
                ),
              ],
            );
          },
          transitionBuilder: (ctx, a1, a2, child) {
            return Transform.scale(
                child: child, scale: Curves.easeOutBack.transform(a1.value));
          },
        );
      },
      icon: const Icon(Icons.flag, size: 20),
      label: Text(AppLocalizations.of(context)!.giveUp),
    );
  }

  Widget _solveButton(BuildContext context, Size screenSize) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) {
        return ScaleTransition(
          child: child,
          scale: anim,
        );
      },
      child: solving
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  primary: Theme.of(context).brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  side: BorderSide(
                      width: 2,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white)),
              onPressed: () {
                stoppedSolving();
              },
              icon: const Icon(Icons.stop),
              label: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(fontSize: min(size.shortestSide / 36, 18)),
              ),
            )
          : puzzle.isComplete()
              ? const SizedBox(height: 28)
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32))),
                  onPressed: () {
                    solve();
                  },
                  icon: const Icon(Icons.extension, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.solve,
                    style: TextStyle(fontSize: min(size.shortestSide / 36, 18)),
                  ),
                ),
    );
  }

  Widget _toggle(BuildContext context, Size screenSize) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: showIndicator,
        onChanged: (_) => showIndicatorChanged(),
      ),
      InkWell(
        child: Text(AppLocalizations.of(context)!.showHelp),
        onTap: showIndicatorChanged,
      ),
    ]);
  }

  Widget _renderSelectedWidget(BuildContext context) {
    final selectedChildWidget = ClipRRect(
      child: selectedWidget ?? const SizedBox(),
      borderRadius: BorderRadius.circular(8),
    );
    Widget renderSelectedWidget;
    if (size.height == size.shortestSide) {
      renderSelectedWidget =
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // const SizedBox(width: 40),
        AspectRatio(
          child: Container(
            child: selectedChildWidget,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2)
                ]),
          ),
          aspectRatio: 1,
        ),
        SizedBox(
          width: size.width / 80,
        ),
        FloatingActionButton.small(
          // backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => _showWidgetPickerDialog(context),
          child: const Icon(Icons.edit),
        ),
      ]);
    } else {
      renderSelectedWidget = Stack(children: [
        Padding(
          child: AspectRatio(
            child: Container(
              child: selectedChildWidget,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 2)
                  ]),
            ),
            aspectRatio: 1,
          ),
          padding: EdgeInsets.only(bottom: 24),
        ),
        Positioned.fill(
          child: Align(
              child: FloatingActionButton.small(
                onPressed: () => _showWidgetPickerDialog(context),
                child: const Icon(Icons.edit),
              ),
              alignment: Alignment.bottomCenter),
        )
      ]);
    }
    return renderSelectedWidget;
  }

  Widget _separator(BuildContext context) {
    return Padding(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color
                    ?.withOpacity(0.26),
              ),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
