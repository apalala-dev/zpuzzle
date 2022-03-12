import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_puzzle/model/puzzle.dart';

class StartedControlsButtons extends AnimatedWidget {
  final bool solving;
  final Puzzle puzzle;
  final Size size;
  final VoidCallback giveUp;
  final VoidCallback solve;
  final VoidCallback stoppedSolving;

  const StartedControlsButtons({
    Key? key,
    required Listenable listenable,
    required this.solving,
    required this.puzzle,
    required this.size,
    required this.giveUp,
    required this.solve,
    required this.stoppedSolving,
  }) : super(listenable: listenable, key: key);

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      child: FadeTransition(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _giveUpButton(context, size),
              _solveButton(context, size),
            ],
          ),
          opacity: _animation),
      scale: _animation.value,
    );
  }

  Widget _giveUpButton(BuildContext context, Size screenSize) {
    return TextButton.icon(
      style:
          TextButton.styleFrom(primary: Colors.red, padding: EdgeInsets.zero),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
}

// Ajouter ici les boutons give up et solve (les animer avec de l'opacité eux)
// Probablement give up à gauche, solve à droite et mettre le gyroscope au milieu (peut-être le changeur de thème aussi)
