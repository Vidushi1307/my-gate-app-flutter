import 'package:flutter/material.dart';

class MenuItem{
  final String text;
  final IconData icon;
  final Color? color;
  
  const MenuItem({
    required this.text,
    required this.icon,
    this.color,
  });
}
