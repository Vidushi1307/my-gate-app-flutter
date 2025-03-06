// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, avoid_print, must_be_immutable
import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';
import 'package:my_gate_app/screens/admin/utils/textbox.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';

class oldVisitorSeacrch extends StatefulWidget {
  const oldVisitorSeacrch({
    super.key,
    required this.username,
    required this.phonenumber,
    this.userid,
  });

  final String username;
  final String phonenumber;
  final int? userid;

  @override
  _oldVisitorSeacrchState createState() => _oldVisitorSeacrchState();
}

class _oldVisitorSeacrchState extends State<oldVisitorSeacrch> {
  String visitor_name = "";
  String mobile_number = "";
  String car_number = "";
  List<String> authorities = [];
  String purpose = "";
  String num_additional = "";

  List<String> duration = ["30 min", "1 hour", "2 hours", "> 2 hours"];

  String authority_name = "None";
  String authority_email = "None";
  String authority_designation = "None";
  String duration_of_stay = "None";

  final student_message_form_key = GlobalKey<FormState>();

  Future<void> get_authorities_list() async {
    List<String> authorities_backend =
        await databaseInterface.get_authorities_list();
    setState(() {
      authorities = authorities_backend;
    });
  }

  @override
  void initState() {
    super.initState();
    get_authorities_list();
    visitor_name = widget.username;
    mobile_number = widget.phonenumber;
  }

  void display_further_status(int statusCode) {
    Navigator.of(context).pop();
    if (statusCode == 200) {
      final snackBar =
          get_snack_bar("Ticket raised successfully", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Failed to raise ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Color.fromARGB(255, 180, 180, 180),
        //   centerTitle: true,
        //   flexibleSpace: Container(
        //     decoration: BoxDecoration(
        //         gradient: LinearGradient(
        //             begin: Alignment.centerLeft,
        //             end: Alignment.centerRight,
        //             colors: <Color>[Colors.purple, Colors.blue])),
        //   ),
        // ),
        body: SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexToColor(guardColors[0]), hexToColor(guardColors[1])],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(children: [
          (widget.userid != null)
              ? Text(
                  "Visitor ID: ${widget.userid}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                )
              : Column(),
          Text(
            widget.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Phone number: ${widget.phonenumber}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          dropdown(
            context,
            authorities,
            (String? s) {
              if (s != null) {
                int idx = s.indexOf("\n");
                var list_authority = [
                  s.substring(0, idx).trim(),
                  s.substring(idx + 1).trim()
                ];
                idx = list_authority[0].indexOf(", ");
                var list_auth_name_design = [
                  list_authority[0].substring(0, idx).trim(),
                  list_authority[0].substring(idx + 1).trim()
                ];

                authority_name = list_auth_name_design[0];
                authority_designation = list_auth_name_design[1];
                authority_email = list_authority[1];
              }
            },
            "Choose Authority",
            Icon(
              Icons.person,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          dropdown(
            context,
            duration,
            (String? s) {
              if (s != null) {
                duration_of_stay = s;
              }
            },
            "Duration of stay",
            Icon(
              Icons.access_time_outlined,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          TextBoxCustom(
            labelText: "Vehicle Number",
            onChangedFunction: (value) {
              car_number = value!;
            },
            icon: const Icon(
              Icons.directions_car_outlined,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          TextBoxCustom(
            labelText: "Purpose of visit",
            onChangedFunction: (value) {
              purpose = value!;
            },
            icon: const Icon(
              Icons.message,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          TextBoxCustom(
            labelText: "Number of additional visitors",
            onChangedFunction: (value) {
              num_additional = value!;
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
          SizedBox(height:MediaQuery.of(context).size.height*0.01),
          SubmitButton(
            button_text: "Generate",
            submit_function: () async {
              print("purpose=$purpose,number=$num_additional");
              int statusCode =
                  await databaseInterface.insert_in_visitors_ticket_table(
                      visitor_name,
                      mobile_number,
                      car_number,
                      authority_name,
                      authority_email,
                      authority_designation,
                      purpose,
                      "enter",
                      duration_of_stay,
                      num_additional,
                      "aabbcc@gmail.com"); /*don't touch the dummy id*/
              display_further_status(
                  statusCode); // Used to display the snackbar
            },
          ),
          SizedBox(
            height: 25,
          ),
        ]),
      ),
    ));
  }
}
