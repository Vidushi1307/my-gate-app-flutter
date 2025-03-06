import 'package:flutter/material.dart';

Widget dropdown(
  BuildContext context,
  List<String> parentLocations,
  void Function(String?)? onChangedFunction,
  String label,
  Icon icon, {
  double border_radius= 5,
  Color container_color= Colors.white,
  Color label_color= Colors.black,
  Color text_color= Colors.black,
  Color dropdown_color= Colors.white,
  Color selected_item_color= Colors.black,
}) {
  return Container(
    width: MediaQuery.of(context).size.width / 2,
    color: container_color,
    child: Theme(
      data: ThemeData(
        textTheme: TextTheme(
          titleMedium: TextStyle(
            color: text_color,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
      child:const Text("dropdown commented")
      // child: DropdownSearch<String>(
      //
      //   mode  = Mode.MENU
      //   dropdownSearchDecoration= InputDecoration(
      //     labelText: label,
      //     labelStyle: TextStyle(
      //       color: label_color,
      //       fontWeight: FontWeight.bold,
      //       fontSize: 16.0,
      //     ),
      //     floatingLabelStyle: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //       fontSize: 16.0,
      //     ),
      //     prefixStyle: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //       fontSize: 16.0,
      //     ),
      //     filled: true,
      //     fillColor: Color.fromARGB(255, 255, 255, 255),
      //     enabledBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(border_radius)),
      //       borderSide: BorderSide(
      //         color: Colors.blue,
      //         width: 2,
      //       ),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(border_radius)),
      //       borderSide: BorderSide(
      //         color: Colors.red,
      //         width: 2,
      //       ),
      //     ),
      //     prefixIcon: icon,
      //   ),
      //   clearButtonProps:const ClearButtonProps(
      //     isVisible: true, //
      //   ),
      //
      //   items: parent_locations,
      //   // popupItemDisabled: (String s) => s.startsWith('I'),
      //   onChanged: onChangedFunction,
      //   // selectedItem: "Brazil"
      // ),
    ),
  );
}
