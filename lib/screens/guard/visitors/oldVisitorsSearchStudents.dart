// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, avoid_print, must_be_immutable
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';
import 'package:my_gate_app/screens/admin/utils/textbox.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';

class oldVisitorSeacrchStudent extends StatefulWidget {
  const oldVisitorSeacrchStudent({
    super.key,
    required this.username,
    required this.phonenumber,
    this.userid,
  });

  final String username;
  final String phonenumber;
  final int? userid;

  @override
  _oldVisitorSeacrchStateStudent createState() =>
      _oldVisitorSeacrchStateStudent();
}

class _oldVisitorSeacrchStateStudent extends State<oldVisitorSeacrchStudent> {
  String visitor_name = "";
  String mobile_number = "";
  String car_number = "";
  List<String> students = [];
  String purpose = "";
  String num_additional = "";
  final _formKey = GlobalKey<FormState>();
  List<String> duration = ["30 min", "1 hour", "2 hours", "> 2 hours"];

  String student_name = "None";
  String student_email = "None";
  String student_number = "";
  String duration_of_stay = "None";

  final student_message_form_key = GlobalKey<FormState>();

  Future<void> get_students_list() async {
    // print("cofirmation fo get_all students");
    List<String> students_backend =
        await databaseInterface.get_students_list_for_visitors();
    setState(() {
      students = students_backend;
      // print("get all students = ${students}");
    });
    print(students);
  }

  @override
  void initState() {
    super.initState();
    get_students_list();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexToColor(guardColors[0]), hexToColor(guardColors[1])],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //       colors: const [
              //         Color.fromARGB(255, 255, 255, 255),
              //         Color.fromARGB(255, 255, 255, 255)
              //       ]),
              // ),

              child: Form(
                // Wrap your form with Form widget
                key: _formKey,
                child: Column(children: [
                  SizedBox(
                    height: 15,
                  ),
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
                    students,
                    (String? s) {
                      if (s != null) {
                        print("WAHWAH: $s");
                        student_name = s.split(',')[0];
                        student_email = s.split(',')[1];
                        student_number = s.split(',')[2];
                      }
                    },
                    "Choose Student",
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
                    validatorFunction: (value) {
                      if (value == null || value.isEmpty) {
                        return 'this field is required!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            String phoneNumber = student_number;
                            String url = "tel:$phoneNumber";
                            if (await canLaunchUrl(
                                Uri(scheme: 'tel', path: phoneNumber))) {
                              await launchUrl(
                                  Uri(scheme: 'tel', path: phoneNumber));
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          icon: Icon(
                            Icons.phone,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          label: Text(
                            'Call',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.green),
                          ),
                        ),
                      ),
                      SubmitButton(
                        button_text: "Accept",
                        submit_function: () async {
                          // print("purpose=${purpose},number=${num_additional}");
                          // Used to display the snackbar
                          if (_formKey.currentState!.validate()) {
                            print(_formKey.currentState!.validate());
                            int statusCode = await databaseInterface
                                .insert_in_visitors_ticket_table(
                                    visitor_name,
                                    mobile_number,
                                    car_number,
                                    "XXXYYYZZZ",
                                    "xxxyyyzzz@gmail.com",
                                    /*dummny, don't touch it,
                                                          to get around foreign key constraint*/
                                    "Warden Main Gate",
                                    purpose,
                                    "enter",
                                    duration_of_stay,
                                    num_additional,
                                    student_email);
                            display_further_status(statusCode);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ]),
              )),
        ),
      ),
    );
  }
}
