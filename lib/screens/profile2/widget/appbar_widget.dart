import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  const icon = CupertinoIcons.moon_stars;
  var iconColor = Colors.blue.shade300;
  // var icon_color = Colors.black;
  // if( color == "black"){
  //   icon_color=Colors.black;
  // }
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    iconTheme: IconThemeData(color: iconColor),
    elevation: 0,
    title: const Text(
      'Profile Page',
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 255, 255, 255)),
    ),
    centerTitle: true,
  );
}
