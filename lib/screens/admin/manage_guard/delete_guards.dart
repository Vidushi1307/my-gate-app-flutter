import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/admin/utils/dropdown.dart';
import 'package:my_gate_app/screens/admin/utils/submit_button.dart';

class DeleteGuards extends StatefulWidget {
  const DeleteGuards({super.key});

  @override
  _DeleteGuardsState createState() => _DeleteGuardsState();
}

class _DeleteGuardsState extends State<DeleteGuards> {
  String chosen_delete_guard_name = "None";
  String chosen_delete_guard_email = "None";

  final List<String> guard_names = databaseInterface.getGuardNames();
  List<String> guard_emails = [];

  @override
  void initState() {
    super.initState();
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
              "Remove Guard",
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
                  chosen_delete_guard_email = s;
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
            SubmitButton(
                submit_function: () async {
                  if (chosen_delete_guard_email != "None") {
                    String response = await databaseInterface
                        .delete_guard(chosen_delete_guard_email);
                    print("Response: $response");
                  }
                },
                button_text: "Delete")
          ],
        ),
      ),
    );
  }
}
