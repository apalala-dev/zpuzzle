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

class _SizePickerState extends State<SizePicker> {
  final _dimensions = [2, 3, 4, 5];
  int _selectedDimension = 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Center(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dimensions.length,
                shrinkWrap: true,
                itemBuilder: (context, idx) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight - 40,
                          width: constraints.maxHeight - 40,
                          child: AnimatedPadding(
                            padding: EdgeInsets.all(
                                _selectedDimension == idx ? 0 : 10),
                            duration: 400.milliseconds,
                            curve: Curves.ease,
                            child: InkWell(
                              splashColor: Colors.pink,
                              borderRadius: BorderRadius.circular(
                                  (1 / _dimensions[idx]) * 8),
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
                                            borderRadius: BorderRadius.circular(
                                                (1 / _dimensions[idx]) * 8)),
                                      ),
                                      padding:
                                          EdgeInsets.all(4 / _dimensions[idx]),
                                    );
                                  }),
                              onTap: () {
                                setState(() {
                                  _selectedDimension = idx;
                                });
                                widget.onSizePicked(_dimensions[idx]);
                              },
                            ),
                          ),
                        ),
                        Text("${_dimensions[idx]}x${_dimensions[idx]}")
                      ]);
                })),
      );
    });
  }
}
