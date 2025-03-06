// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

class DeleteLocations extends StatefulWidget {
  const DeleteLocations({super.key});

  @override
  _DeleteLocationsState createState() => _DeleteLocationsState();
}

class _DeleteLocationsState extends State<DeleteLocations> {
  String chosen_delete_location = "None";
  List<String> parent_locations = [];
  // List<String> parent_locations = databaseInterface.getLoctions();
  
  @override
  void initState(){
    super.initState();
    databaseInterface.getLoctions2().then((result){
      setState(() {
        parent_locations=result;
      });
    });
  }

  Future<void> delete_location() async {
    print("submit button of delete location pressed");
    
    // chosen_delete_location = "Main Gate";

    if (chosen_delete_location == "None") {
      print("Display red warning message for chosen_delete_location: Cannot be None");
      final snackBar = get_snack_bar("Chosen delete location: Cannot be None", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String response = await databaseInterface.delete_location(chosen_delete_location);
    if (response == "Location deleted successfully") {
      print("Display snackbar: Location deleted successfully");
      final snackBar = get_snack_bar("Location deleted successfully", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else {
      print("Display snackbar: Failed to delete location");
      final snackBar = get_snack_bar("Failed to delete location", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // print("Display snackbar: " + response);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Colors.lightBlueAccent,
          //     Colors.purple.shade200,
          //   ],
          // ),
              color: Color(0xfff0eded),
        ),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                "Delete Location",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 30),
              ),
              SizedBox(
                height: 50,
              ),
              dropdown(
                context,
                parent_locations,
                (String? s) {
                  if (s != null) {
                    print("inside funciton:$chosen_delete_location");
                    chosen_delete_location = s;
                    print(chosen_delete_location);
                  }
                },
                "Delete Location",
                Icon(
                  Icons.corporate_fare,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              SubmitButton(submit_function: () async {
                delete_location();
              }, button_text: "Delete")
            ],
          ),
        ),
      ),
    );
  }
}
