import 'package:flutter/material.dart';

SnackBar get_snack_bar(
  String message,
  MaterialColor bgColor,
) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          message,
          style: const TextStyle(color: Colors.white,),
        ),
      ],
    ),
    backgroundColor: bgColor,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(10),
  );
}
