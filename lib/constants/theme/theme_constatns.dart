import 'package:flutter/material.dart';
import 'package:Prefer/constants/my_colors.dart';

const COLOR_PRIMARY_Dark = Colors.black;
const COLOR_PRIMARY_Light = Colors.white;
var COLOR_ACCENT_Dark = Colors.black;
var COLOR_ACCENT_Light = MyColors.myRed;

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: COLOR_PRIMARY_Light,
);

ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark()
        .copyWith(primary: Colors.black, secondary: Colors.black),
    backgroundColor: Colors.black);
