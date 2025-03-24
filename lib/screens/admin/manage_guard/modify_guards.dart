import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';

class ModifyGuards extends StatefulWidget {
  const ModifyGuards({super.key});

  @override
  _ModifyGuardsState createState() => _ModifyGuardsState();
}

class _ModifyGuardsState extends State<ModifyGuards> {
  String chosen_modify_guard = "None";
  String chosen_modify_guard_email = "None";
  String chosen_modify_guard_location = "None";
  final List<String> guard_names = databaseInterface.getGuardNames();
  List<String> guard_emails = [];

  List<String> locations = [];

  @override
  void initState() {
    super.initState();
    print("Init state called");
    databaseInterface.getLoctions2().then((result) {
      setState(() {
        locations = result;
      });
    });
    databaseInterface.get_all_guard_emails().then((result) {
      setState(() {
        guard_emails = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Color(0xfff0eded),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Modify Guard",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30),
            ),
            const SizedBox(
              height: 50,
            ),
            dropdown(
              context,
              guard_emails,
              (String? s) {
                if (s != null) {
                  print("inside funciton:$chosen_modify_guard_email");
                  chosen_modify_guard_email = s;
                  print(chosen_modify_guard_email);
                }
              },
              "Guard Email",
              const Icon(
                Icons.email_outlined,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            dropdown(
              context,
              locations,
              (String? s) {
                if (s != null) {
                  chosen_modify_guard_location = s;
                }
              },
              "Guard Location",
              const Icon(
                Icons.corporate_fare,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SubmitButton(
                submit_function: () async {
                  if (chosen_modify_guard_email != "None" &&
                      chosen_modify_guard_location != "None") {
                    String response = await databaseInterface.modify_guard(
                        chosen_modify_guard_email,
                        chosen_modify_guard_location);
                  }
                },
                button_text: "Update")
          ],
        ),
      ),
    );
  }
}
