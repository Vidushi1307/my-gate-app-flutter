// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, unnecessary_this, avoid_print

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';
import 'package:my_gate_app/screens/admin/utils/textbox.dart';

class AddGuards extends StatefulWidget {
  const AddGuards({super.key});

  @override
  _AddGuardsState createState() => _AddGuardsState();
}

class _AddGuardsState extends State<AddGuards> {
  String chosen_guard_location = "None";
  String chosen_pre_approval_needed = "None";
  String new_guard_name = "None";
  String new_guard_email = "None";
  List<String> parent_locations = [];

  final guard_name_form_key = GlobalKey<FormState>();
  final guard_email_form_key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    databaseInterface.getLoctions2().then((result) {
      setState(() {
        parent_locations = result;
      });
    });
  }

  Future<void> add_new_guard() async {
    print("submit button of add new Guard pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Color(0xfff0eded),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "Add New Guard",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30),
            ),
            SizedBox(
              height: 50,
            ),
            TextBoxCustom(
              labelText: "Enter Guard Name",
              onSavedFunction: (value) {
                this.new_guard_name = value!;
              },
              icon: const Icon(
                Icons.security,
                color: Colors.black,
              ),
              form_key: this.guard_name_form_key,
            ),
            SizedBox(
              height: 50,
            ),
            TextBoxCustom(
              labelText: "Enter Guard Email",
              onSavedFunction: (value) {
                this.new_guard_email = value!;
              },
              icon: const Icon(
                Icons.email_outlined,
                color: Colors.black,
              ),
              form_key: this.guard_email_form_key,
            ),
            SizedBox(
              height: 50,
            ),
            dropdown(
              context,
              this.parent_locations,
              (String? s) {
                if (s != null) {
                  this.chosen_guard_location = s;
                }
              },
              "Guard Location",
              Icon(
                Icons.corporate_fare,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SubmitButton(
              submit_function: () async {
                final guard_name_validity =
                    this.guard_name_form_key.currentState?.validate();
                FocusScope.of(context).unfocus();
                if (guard_name_validity != null && guard_name_validity) {
                  this.guard_name_form_key.currentState?.save();
                }
                final guard_email_validity =
                    this.guard_email_form_key.currentState?.validate();
                FocusScope.of(context).unfocus();
                if (guard_email_validity != null && guard_email_validity) {
                  this.guard_email_form_key.currentState?.save();
                }
                if (this.new_guard_name != "None" &&
                    this.new_guard_email != "None" &&
                    this.chosen_guard_location != "None") {
                  String response = await databaseInterface.add_guard(
                      this.new_guard_name,
                      this.new_guard_email,
                      this.chosen_guard_location);
                  print("Response: $response");
                }
                add_new_guard();
              },
              button_text: "Add",
            )
          ],
        ),
      ),
    );
  }
}
