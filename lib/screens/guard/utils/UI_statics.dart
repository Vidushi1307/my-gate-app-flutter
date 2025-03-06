import 'package:flutter/material.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(0, 6), radix: 16) + 0xFF000000);
}

List<String> guardColors = ["EEF0E8", "A7AF95", "3F443E"];