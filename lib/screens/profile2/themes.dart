import 'package:flutter/material.dart';

class MyThemes {
  static const primary = Colors.blue;
  // static final primary = Colors.blue.shade300;
  static final primaryColor = Colors.blue.shade300;

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColorDark: primaryColor,
    colorScheme: const ColorScheme.dark(primary: primary),
    dividerColor: Colors.white,
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    // scaffoldBackgroundColor: Colors.blue.shade300,
    primaryColor: primary,
    // primaryColor: Colors.blue.shade300,
    colorScheme: const ColorScheme.light(primary: primary),
    dividerColor: Colors.black,
  );
}