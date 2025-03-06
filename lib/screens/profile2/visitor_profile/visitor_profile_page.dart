// ignore_for_file: non_constant_identifier_names, unused_local_variable, unnecessary_new

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
// import 'package:my_gate_app/screens/profile2/guard_profile/guard_edit_profile_page.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorProfilePage extends StatefulWidget {
  final ResultObj4 visitorObject;
  final bool isEditable;
  const VisitorProfilePage(
      {super.key, required this.visitorObject, required this.isEditable});
  @override
  _VisitorProfilePageState createState() => _VisitorProfilePageState();
}

class _VisitorProfilePageState extends State<VisitorProfilePage> {
  late final TextEditingController controller_name;
  late final TextEditingController controller_mobile_no; //
  late final TextEditingController controller_car_number; //
  late final TextEditingController controller_purpose; //
  late final TextEditingController controller_authority_message;

  /// give procedure to
  late final TextEditingController controller_date_time_of_ticket_raised; //
  // late final TextEditingController controller_date_time_authority; /// capture it
  late final TextEditingController controller_duration_of_stay; //

  Future<void> init() async {
    databaseInterface db = new databaseInterface();
    controller_name.text = widget.visitorObject.visitor_name;
    controller_mobile_no.text = widget.visitorObject.mobile_no;
    controller_car_number.text = widget.visitorObject.car_number;
    controller_purpose.text = widget.visitorObject.purpose;
    controller_authority_message.text = widget.visitorObject.authority_message;

    var date_time = widget.visitorObject.date_time_of_ticket_raised;
    date_time =
        "${date_time.split("T")[1].split(".")[0]} ${date_time.split("T")[0]}";

    controller_date_time_of_ticket_raised.text = date_time;
    // controller_date_time_authority.text = widget.visitorObject.date_time_authority ;
    controller_duration_of_stay.text = widget.visitorObject.duration_of_stay;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller_name = TextEditingController();
    controller_mobile_no = TextEditingController();
    controller_car_number = TextEditingController();
    controller_purpose = TextEditingController();
    controller_authority_message = TextEditingController();
    controller_date_time_of_ticket_raised = TextEditingController();
    // controller_date_time_authority = TextEditingController();
    controller_duration_of_stay = TextEditingController();
    init();
  }

  void display_further_status(int statusCode) {
    Navigator.of(context).pop();
    if (statusCode == 200) {
      final snackBar = get_snack_bar("Action successful", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Action failed", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF0D2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'Ticket Details',
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.065,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 24),
          builText(controller_name, "Full Name", false, 1),
          const SizedBox(height: 24),
          builText(controller_mobile_no, "Mobile No", false, 1),
          const SizedBox(height: 24),
          builText(controller_car_number, "Car Number", false, 1),
          const SizedBox(height: 24),
          builText(controller_purpose, "Purpose", false, 1),
          const SizedBox(height: 24),
          builText(controller_authority_message, "Authority Message",
              widget.isEditable, 1),
          const SizedBox(height: 24),
          builText(controller_date_time_of_ticket_raised,
              "Ticket Generation Time", false, 1),
          const SizedBox(height: 24),
          builText(controller_duration_of_stay, "Duration of Visit", false, 1),
          const SizedBox(height: 24),
          if (widget.isEditable)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    widget.visitorObject.authority_message =
                        controller_authority_message.text;
                    print("calling insert_in_visitors_ticket_table_2");
                    int statusCode = await databaseInterface
                        .insert_in_visitors_ticket_table_2(
                            "Approved", widget.visitorObject);
                    print("status code: $statusCode");
                    display_further_status(
                        statusCode); // Used to display the snackbar
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15)),
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 15, color: Colors.black)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                      ),
                    ),

                  ),
                  child: Text(
                      "Approve Ticket",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    widget.visitorObject.authority_message =
                        controller_authority_message.text;
                    int statusCode = await databaseInterface
                        .insert_in_visitors_ticket_table_2(
                            "Rejected", widget.visitorObject);
                    display_further_status(
                        statusCode); // Used to display the snackbar
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15)),
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 15, color: Colors.black)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                      ),
                    ),
                  ),
                  child:  Text("Reject Ticket",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                    ),
                  )
                ),
              ],
            ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget builText(TextEditingController controller, String label,
          final bool enabled, int maxLines) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: enabled,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto', // Change the font family as needed
              fontSize: 16.0, // Adjust the font size as needed
            ),
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFDE4B2), // Set the background color
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0), // Adjust the padding as needed
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust the border radius as needed
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 36, 0, 108),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust the border radius as needed
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust the border radius as needed
              ),
            ),
            maxLines: maxLines,
          ),
        ],
      );
}
