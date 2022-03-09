import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class SizePicker extends StatefulWidget {
  final Function(int) onSizePicked;

  const SizePicker({Key? key, required this.onSizePicked}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SizePickerState();
  }
}

class _SizePickerState extends State<SizePicker>
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
      return SizedBox(
        height: constraints.maxHeight,
        width: (constraints.maxHeight) * _dimensions.length,
        child: Center(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dimensions.length,
                shrinkWrap: true,
                itemBuilder: (context, idx) {
                  return InkWell(
                    borderRadius:
                        BorderRadius.circular((1 / _dimensions[idx]) * 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedBuilder(
                        animation: _anims[_dimensions[idx]]!,
                        child: Column(
                          children: [
                            SizedBox(
                                height: constraints.maxHeight - 20,
                                width: constraints.maxHeight - 20,
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        _dimensions[idx] * _dimensions[idx],
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: _dimensions[idx]),
                                    itemBuilder: (ctx, i) {
                                      return Padding(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      (1 / _dimensions[idx]) *
                                                          8)),
                                        ),
                                        padding: EdgeInsets.all(
                                            4 / _dimensions[idx]),
                                      );
                                    })),
                            SizedBox(
                              child: Text(
                                  "${_dimensions[idx]}x${_dimensions[idx]}"),
                              height: 20,
                            )
                          ],
                        ),
                        builder: (ctx, child) {
                          return Transform.scale(
                              scale: _anims[_dimensions[idx]]!.value,
                              child: child);
                        },
                      ),
                    ),
                    onTap: () {
                      if (_selectedDimension != idx) {
                        _animateSelection(_selectedDimension, idx);
                        widget.onSizePicked(_dimensions[idx]);
                      }
                    },
                  );
                })),
      );
    });
  }
}
