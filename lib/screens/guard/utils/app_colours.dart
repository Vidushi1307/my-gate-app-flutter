import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';

class AppColors {
  // Primary colors from your guardColors
  static Color primaryColor = hexToColor(guardColors[0]);
  static Color secondaryColor = hexToColor(guardColors[2]);
  
  // Text colors
  static Color darkText = Colors.black;
  static Color lightText = Color(0xFF636060);
  static Color whiteText = Colors.white;
  
  // Background colors
  static Color scaffoldBackground = Colors.white;
  
  // Helper function (from your existing code)
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
