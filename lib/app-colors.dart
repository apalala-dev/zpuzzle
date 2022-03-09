import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';

class AppColors {
  static final primaryColor = HexColor('FEA14B');
  static final accentColor = HexColor('9FEBFC');

  static Color fogColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? HexColor('1F5A79')
          : HexColor('004366');

  static Color boardInnerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? _boardInnerColorLight
          : _boardInnerColorDark;

  static Color boardOuterColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? _boardOuterColorLight
          : _boardOuterColorDark;

  static final _boardInnerColorDark = HexColor('A3A3A3');
  static final _boardOuterColorDark = HexColor('424242');
  static final _boardInnerColorLight = HexColor('E9DBC6');
  static final _boardOuterColorLight = HexColor('997A5E');
  // static final _boardInnerColorLight = HexColor('F7FFE0');
  // static final _boardOuterColorLight = HexColor('BCD083');

  static final perspectiveColor = HexColor('363636');

  AppColors._();
}
