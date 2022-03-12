import 'package:flutter/material.dart';

import '../../asset_path.dart';
import 'background_widget_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WidgetPickerDialog {
  WidgetPickerDialog._();

  static void show(BuildContext context, Widget currentlySelectedWidget,
      Function(Widget) onWidgetPicked) {
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
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 2,
              child: BackgroundWidgetPicker(
                  crossAxisCount:
                      (MediaQuery.of(context).size.width / 200).round(),
                  baseWidget: const Image(
                      image: AssetImage(AssetPath.img05), fit: BoxFit.cover),
                  currentlySelectedWidget: currentlySelectedWidget,
                  onBackgroundPicked: (sw) {
                    Future.delayed(const Duration(milliseconds: 300),
                        () => Navigator.pop(context, sw));
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
            child: FadeTransition(
              child: child,
              opacity: a1,
            ),
            scale: Curves.easeOutBack.transform(a1.value));
      },
    ).then((newWidget) {
      if (newWidget != null && newWidget is Widget) {
        onWidgetPicked(newWidget);
      }
    });
  }
}
