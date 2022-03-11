import 'package:flutter/material.dart';

class BasicApp extends StatelessWidget {
  const BasicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(title: const Text('A real app bar')),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Use almost any widget'),
                ElevatedButton(
                    onPressed: () {},
                    child: const Text('A real ElevatedButton')),
                Slider(
                  value: 65,
                  max: 100,
                  divisions: 20,
                  label: 'A Slider',
                  onChanged: (double value) {},
                ),
              ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {},
          ),
        ));
  }
}
