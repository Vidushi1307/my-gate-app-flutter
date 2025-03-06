import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/screens/admin/utils/textbox.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

class InviteeValidationPage extends StatefulWidget {
  final String ticket_id;
  const InviteeValidationPage({super.key, required this.ticket_id});

  @override
  State<InviteeValidationPage> createState() => _InviteeValidationPageState();
}

class _InviteeValidationPageState extends State<InviteeValidationPage> {
  String invitee_name = "Loading ...";
  String student_name = "Loading ...";
  String vehicle_number = "";
  String relationship_with_student = "Loading ...";
  String enter_exit = "";

  Future<void> getTicketDetails() async {
    Map<String, String> data =
        await databaseInterface.getInviteeRequestByTicketID(widget.ticket_id);
    setState(() {
      invitee_name = data['invitee_name']!;
      student_name = data['student_name']!;
      relationship_with_student = data['relationship_with_student']!;
      vehicle_number=data['vehicle_number']!;
    });
  }
  void display_further_status(int statusCode) {
    Navigator.of(context).pop();
    if (statusCode == 200) {
      final snackBar =
          get_snack_bar("Request Accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Request Failed", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTicketDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: hexToColor(guardColors[0]),
          title: const Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text('Invitee Form'),
            ],
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  hexToColor(guardColors[0]),
                  hexToColor(guardColors[1])
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          _buildLabel("Invitee Name"),
                          const SizedBox(height: 5),
                          _buildTextField(invitee_name,
                              MediaQuery.of(context).size.width * 0.7),
                          const SizedBox(height: 25),
                          _buildLabel("Student name (Invited by)"),
                          const SizedBox(height: 5),
                          _buildTextField(student_name,
                              MediaQuery.of(context).size.width * 0.7),
                          const SizedBox(height: 25),
                          _buildLabel("Relationship with student"),
                          const SizedBox(height: 5),
                          _buildTextField(relationship_with_student,
                              MediaQuery.of(context).size.width * 0.7),
                          const SizedBox(height: 30),
                          TextBoxCustom(
                            labelText: "Vehicle Number",
                            onChangedFunction: (value) {
                              vehicle_number = value!;
                            },
                            icon: const Icon(
                              Icons.directions_car_outlined,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          dropdown(
                            context,
                            ["Enter", "Exit"],
                            (String? s) {
                              if (s != null) {
                                if (s == 'Enter') {
                                  enter_exit = "enter";
                                } else if (s == "Exit") {
                                  enter_exit = "exit";
                                }
                              }
                            },
                            "Enter or Exit Request",
                            const Icon(
                              Icons.access_time_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    SubmitButton(
                      button_text: "Accept",
                      submit_function: () async {
                        int statusCode =
                            await databaseInterface.guardCreateInviteeRecord(
                                widget.ticket_id, vehicle_number, enter_exit);
                                display_further_status(statusCode);
                      },
                    ),
                  ]),
            )));
  }
}

Widget _buildLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.grey[600],
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _buildTextField(String text, double width) {
  return Container(
    padding: const EdgeInsets.all(10),
    width: width,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    ),
  );
}
