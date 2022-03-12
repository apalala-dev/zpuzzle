import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PuzzleSizePicker extends StatefulWidget {
  final bool horizontal;
  final Function(int) onSizePicked;

  const PuzzleSizePicker({
    Key? key,
    required this.onSizePicked,
    required this.horizontal,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PuzzleSizePickerState();
  }
}

class _PuzzleSizePickerState extends State<PuzzleSizePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Map<int, Animation<double>> _anims;
  final _dimensions = [2, 3, 4, 5];
  int _selectedDimension = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animateSelection(-1, _selectedDimension, updateUi: false);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  _animateSelection(int idxPreviousSelection, int idxNewSelection,
      {bool updateUi = true}) {
    final previousDim =
        idxPreviousSelection == -1 ? -1 : _dimensions[idxPreviousSelection];
    final newDim = _dimensions[idxNewSelection];
    _anims = {};

    for (var d in _dimensions) {
      if (d == previousDim) {
        _anims[d] =
            Tween<double>(begin: 1.0, end: 0.7).animate(_animationController);
      } else if (d == newDim) {
        _anims[d] =
            Tween<double>(begin: 0.7, end: 1.0).animate(_animationController);
      } else {
        _anims[d] = const AlwaysStoppedAnimation(0.7);
      }
    }
    if (updateUi) {
      setState(() {
        _selectedDimension = idxNewSelection;
        // _animationController = AnimationController(
        //     vsync: this, duration: const Duration(milliseconds: 3000));
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final minSize = min(constraints.maxWidth, constraints.maxHeight);
      return Container(
        decoration: BoxDecoration(
            color: Colors.white12, borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.all(minSize / 20),
        child: Column(children: [
          Text(AppLocalizations.of(context)!.difficulty,
              style: TextStyle(
                  fontSize: min(
                      constraints.maxWidth > constraints.maxHeight
                          ? constraints.maxHeight / 4
                          : constraints.maxWidth / 6,
                      20))),
          Expanded(
              child: Padding(
            child: Column(
              children: widget.horizontal
                  ? [
                      Expanded(
                        child: Row(children: [
                          Expanded(child: _clickableChild(constraints, 0)),
                          Expanded(child: _clickableChild(constraints, 1)),
                          Expanded(child: _clickableChild(constraints, 2)),
                          Expanded(child: _clickableChild(constraints, 3))
                        ]),
                      )
                    ]
                  : [
                      Expanded(
                          child: Row(children: [
                        Expanded(child: _clickableChild(constraints, 0))
                      ])),
                      Expanded(
                          child: Row(children: [
                        Expanded(child: _clickableChild(constraints, 1))
                      ])),
                      Expanded(
                          child: Row(children: [
                        Expanded(child: _clickableChild(constraints, 2))
                      ])),
                      Expanded(
                          child: Row(children: [
                        Expanded(child: _clickableChild(constraints, 3))
                      ])),
                    ],
            ),
            padding: EdgeInsets.only(
                left: minSize / 20, right: minSize / 20, top: minSize / 20),
          )),
        ]),
      );
    });
  }

  Widget _clickableChild(BoxConstraints constraints, int idx) {
    return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular((1 / _dimensions[idx]) * 8),
        child: InkWell(
          borderRadius: BorderRadius.circular((1 / _dimensions[idx]) * 8),
          child: AnimatedBuilder(
            animation: _anims[_dimensions[idx]]!,
            child: _child(constraints, idx),
            builder: (ctx, child) {
              return Transform.scale(
                  scale: _anims[_dimensions[idx]]!.value, child: child);
            },
          ),
          onTap: () {
            if (_selectedDimension != idx) {
              _animateSelection(_selectedDimension, idx);
              widget.onSizePicked(_dimensions[idx]);
            }
          },
        ));
  }

  Widget _child(BoxConstraints constraints, int idx) {
    var color = Theme.of(context).textTheme.titleLarge!.color!;
    if (idx != _selectedDimension) {
      color = color.withOpacity(0.6);
    }
    return Container(
      child: constraints.maxWidth < constraints.maxHeight
          ? Column(children: [
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.extension,
                        color: color, size: constraints.maxWidth / 6),
                    SizedBox(width: constraints.maxWidth / 80),
                    Text("${_dimensions[idx]}x${_dimensions[idx]}",
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: constraints.maxWidth / 6))
                  ]))
            ])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.extension,
                  color: color, size: constraints.maxHeight / 5),
              Text("${_dimensions[idx]}x${_dimensions[idx]}",
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: constraints.maxHeight / 5))
            ]),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((1 / _dimensions[idx]) * 16),
          border: Border.all(width: 2, color: color)),
    );
  }
}
