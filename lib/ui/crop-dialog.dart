import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class CropDialog extends StatefulWidget {
  final Uint8List imageData;

  const CropDialog({Key? key, required this.imageData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropDialogState();
  }

  static Future<Uint8List?> show(BuildContext context,
      {required Uint8List imageData}) {
    return showDialog<Uint8List>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: CropDialog(
              imageData: imageData,
            ),
          );
        });
  }
}

class _CropDialogState extends State<CropDialog> {
  final _controller = CropController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(500.milliseconds, () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(children: [
      SizedBox(
          width: size.width * 0.7,
          height: size.height * 0.7,
          child: isLoading
              ? const CircularProgressIndicator()
              : Crop(
                  image: widget.imageData,
                  controller: _controller,
                  onCropped: (image) {
                    // do something with image data
                    Navigator.of(context).pop(image);
                  },
                  aspectRatio: 1,
                  initialSize: 0.5,
                  // initialArea: Rect.fromLTWH(240, 212, 800, 600),
                  // withCircleUi: true,
                  baseColor: Colors.blue.shade900,
                  maskColor: Colors.black.withAlpha(100),
                )),
      const SizedBox(
        height: 20,
      ),
      ElevatedButton(
          onPressed: () {
            _controller.crop();
            setState(() {
              isLoading = true;
            });
          },
          child: Text("CROP"))
    ]);
  }
}
