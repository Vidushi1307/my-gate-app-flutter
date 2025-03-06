// ignore_for_file: unnecessary_new, deprecated_member_use, non_constant_identifier_names, prefer_const_constructors, unnecessary_this, unnecessary_brace_in_string_interps, avoid_unnecessary_containers, must_be_immutable

import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentStatus extends StatefulWidget {
  StudentStatus({
    super.key,
    required this.location,
    required this.in_or_out,
    required this.inside_parent_location,
    required this.exited_all_children,
    required this.pre_approval_required,
  });

  final String location;
  String in_or_out; // "in", "pending_entry", "out", "pending_out"
  String inside_parent_location; // "true" or "false"
  String exited_all_children; // "true" or "false"
  bool pre_approval_required;

  @override
  _StudentStatusState createState() => _StudentStatusState();
}

class _StudentStatusState extends State<StudentStatus> {
  String ticket_raised_message = '';
  String exit_ticket_raised_message = '';
  String parent_location = '';
  String choosen_authority_ticket = "None";
  List<String> enter_authorities_tickets = [];
  List<String> exit_authorities_tickets = [];
  var user = UserPreferences.myUser;
  final TextEditingController _destinationAddressController =
      TextEditingController();
  final TextEditingController _vehicleRegisterationController =
      TextEditingController();

  Future<void> get_parent_location_name() async {
    String parent_location_local =
        await databaseInterface.get_parent_location_name(widget.location);
    setState(() {
      parent_location = parent_location_local;
    });
  }

  Future<void> get_authority_tickets_with_status_accepted() async {
    String email = LoggedInDetails.getEmail();
    if (widget.in_or_out == "out") {
      List<String> enter_authorities_tickets_local =
          await databaseInterface.get_authority_tickets_with_status_accepted(
              email, widget.location, "enter");
      setState(() {
        enter_authorities_tickets = enter_authorities_tickets_local;
      });
    } else if (widget.in_or_out == "in") {
      List<String> exit_authorities_tickets_local =
          await databaseInterface.get_authority_tickets_with_status_accepted(
              email, widget.location, "exit");
      setState(() {
        exit_authorities_tickets = exit_authorities_tickets_local;
      });
    }
  }

  void generateQRButton(
      String address, String email, String veh_num, String ticket_type) {
        //to reduce the data length of hte qr data for quick error less scan 
        Map<String,String> obj={
          "type":"student",
          "add":address,
          "eml":email,
          "v_n":veh_num,
          "tic_ty":ticket_type,
          "s_lc":widget.location,
        };
    String qrData =jsonEncode(obj);
    print("Location of student=${widget.location}");

    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          color: Colors.transparent, // Set the container's color to transparent
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            // child: Center(
            //   child: QrImageView(
            //     data: qrData,
            //     backgroundColor: Colors.white,
            //     size: 200,
            //   ),
            // ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Show QR code to the guard',style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),),
                Text('Email: ${email}',style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),),
                Text('Ticket Type: ${ticket_type}',style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),),
                SizedBox(height: 16), // Add some spacing
                Center(
                  child: QrImageView(
                    data: qrData,
                    backgroundColor: Colors.white,
                    size: 200,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    get_parent_location_name();
    get_authority_tickets_with_status_accepted();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white, // Change the color of background

        // ///////////////////////////
        //       decoration: BoxDecoration(
        //           // gradient: LinearGradient(
        //           //   begin: Alignment.topRight,
        //           //   end: Alignment.bottomLeft,
        //           //   stops: [
        //           //     0.1,
        //           //     0.4,
        //           //     0.6,
        //           //     0.9,
        //           //   ],
        //           //   colors: [
        //           //     Colors.yellow.withOpacity(0.3),
        //           //     Colors.red.withOpacity(0.3),
        //           //     Colors.indigo.withOpacity(0.3),
        //           //     Colors.teal.withOpacity(0.3),
        //           //   ],
        //           // )

        //           gradient: LinearGradient(
        //   colors: [
        //     Colors.white,
        //     Colors.white70,
        //   ],
        // ),
        //         ),

        // ///////////////////////////

        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height /
                    2.6, // Half of the screen height
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(10), // Adjust the radius as needed
                    bottomRight: Radius.circular(10),

                    // Adjust the radius as needed
                  ),
                  image: DecorationImage(
                    image:
                        AssetImage(databaseInterface.getImagePath(widget.location)), // Your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Wrap(
                  children: [
                    getStatusSection(),
                    // Row(
                    //   children:  [
                    //     SizedBox(
                    //       width:MediaQuery.of(context).size.width*1,
                    //       child: Center(
                    //         child: ListTile(
                    //           leading: Icon(
                    //             Icons.location_on,
                    //             color: Colors.black,
                    //           ),
                    //           title: Text(
                    //             'Floor 202,Room 302 Ramanujan Block', // Update with your address text
                    //             style: TextStyle(
                    //               fontSize: 15,
                    //               color: Colors.black,
                    //             ),
                    //
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //
                    //   ],
                    // ),
                    // ListTile(
                    //   title: Text(
                    //     '8:00 AM - 9:00 PM', // Time text
                    //     style: TextStyle(
                    //       fontSize: 15,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),
                    if (widget.pre_approval_required) getDropDownMenu(),

                    getButtonSection(),

                    // Center(
                    //   child: RaisedButton(
                    //     onPressed: () {
                    //       /*generate QR*/
                    //       generateQRButton(
                    //           "NA", LoggedInDetails.getEmail(), "NA", "enter");
                    //     },
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(80.0)),
                    //     padding: EdgeInsets.all(0.0),
                    //     child: Ink(
                    //       decoration: BoxDecoration(
                    //         gradient: LinearGradient(
                    //           // colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                    //           colors: [Colors.black, Colors.black],
                    //           begin: Alignment.centerLeft,
                    //           end: Alignment.centerRight,
                    //         ),
                    //         borderRadius: BorderRadius.circular(30.0),
                    //       ),
                    //       child: Container(
                    //         constraints:
                    //             BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                    //         alignment: Alignment.center,
                    //         child: Text(
                    //           "Generate QR",
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget getDropDownMenu() {
    if (widget.in_or_out == 'out') {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          // Container(
          //   margin: const EdgeInsets.all(15.0),
          //   child: dropdown(
          //     context,
          //     this.enter_authorities_tickets,
          //     (String? s) {
          //       if (s != null) {
          //         // print("inside funciton:" + this.chosen_parent_location);
          //         this.choosen_authority_ticket = s;
          //         // print(this.chosen_parent_location);
          //       }
          //     },
          //     "Choose Authority Ticket",
          //     Icon(
          //       Icons.corporate_fare,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ],
      ));
    } else if (widget.in_or_out == 'in') {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container(
          //   margin: const EdgeInsets.all(15.0),
          //   child: dropdown(
          //     context,
          //     this.exit_authorities_tickets,
          //     (String? s) {
          //       if (s != null) {
          //         // print("inside funciton:" + this.chosen_parent_location);
          //         this.choosen_authority_ticket = s;
          //         // print(this.chosen_parent_location);
          //       }
          //     },
          //     "Choose Authority Ticket",
          //     Icon(
          //       Icons.corporate_fare,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.all(15.0),
            width: MediaQuery.of(context).size.width / 1.5,
            child: TextField(
              controller: _destinationAddressController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Destination Address',
                hintStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(15.0),
            width: MediaQuery.of(context).size.width / 1.5,
            child: TextField(
              controller: _vehicleRegisterationController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Vehicle Registeration Number',
                hintStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
    } else {
      return Text("");
    }
  }

  // This represents the top half of the page
  Widget getStatusSection() {
    // print("getStatusSection called with in_or_out value: " + widget.in_or_out);
    if (widget.in_or_out == 'in') {
      return StatusIN(location: widget.location);
    } else if (widget.in_or_out == 'pending_entry') {
      return StatusPendingEntry(location: widget.location);
    } else if (widget.in_or_out == 'pending_exit') {
      return StatusPendingExit(location: widget.location);
    } else if (widget.in_or_out == 'out') {
      return StatusOUT(location: widget.location);
    } else {
      return Text("Invalid Status",
          style: TextStyle(
            fontSize: 20,
          ));
    }
  }

  //  This represents the bottom half of the page
  Widget getButtonSection() {
    // print("getButtonSection called with in_or_out value: " + widget.in_or_out);
    if (widget.in_or_out == 'out') {
      if (widget.inside_parent_location == "true") {
        return Column(
          children: [
            // EnterButton(
            //   enter_function: show_popup,
            //   enter_message: this.ticket_raised_message,
            // ),
            SizedBox(height: 30),
            Center(
              child: MaterialButton(
                onPressed: () {
                  /*generate QR*/
                  generateQRButton(
                      "NA", LoggedInDetails.getEmail(), "NA", "enter");
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                padding: EdgeInsets.all(0.0),
                color: Colors.black,
                child: Ink(
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 24, // Adjust the size as needed
                        ),
                        SizedBox(width:10 ),
                        Text(
                          "Generate QR",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mPlusRounded1c(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height:20 ),

          ],
        );
      } else {
        return Text(
          "Cannot enter this location if not entered its parent location - ${parent_location}",
          textAlign: TextAlign.center,
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    } else if (widget.in_or_out == 'in') {
      if (widget.exited_all_children == "true") {
        return Column(
          children: [
            // ExitButton(
            //   exit_function: show_popup,
            //   exit_message: this.exit_ticket_raised_message,
            // ),
            SizedBox(height: 30),
            Center(
              child: MaterialButton(
                onPressed: () {
                  /*generate QR*/
                  generateQRButton(
                      _destinationAddressController.text,
                      LoggedInDetails.getEmail(),
                      _vehicleRegisterationController.text,
                      "exit");
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                padding: EdgeInsets.all(0.0),
                color: Colors.black,
                child: Ink(
                  child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 24, // Adjust the size as needed
                          ),
                          SizedBox(width:10 ),

                          Text(
                            "Generate QR",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mPlusRounded1c(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        ],
                      )),
                ),
              ),
            ),
            SizedBox(height:20 ),
          ],
        );
      } else {
        return Text(
          "Cannot exit this location if not exited all its children location",
          textAlign: TextAlign.center,
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    } else {
      return Text("");
    }
  }

  void display_further_status(int statusCode, String person_status) {
    Navigator.of(context).pop();
    if (statusCode == 200) {
      setState(() {
        // After adding the entry, update the status to "pending_entry"
        widget.in_or_out = person_status;
      });
    } else {
      // snackbar
      final snackBar = get_snack_bar("Failed to raise ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // This function is used to show the pop up when one press enter button
  show_popup(String ticket_type) {
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new ListBody(
              children: [
                new Text('Are you sure you want to $ticket_type ?'),
              ],
            ),
          ),
          actions: [
            // If one press the Yes button of the popup
            new TextButton(
              child: new Text('Yes'),
              onPressed: () async {
                int statusCode;
                if (ticket_type == "enter") {
                  statusCode = await enter_button_pressed();
                  display_further_status(statusCode, "pending_entry");
                } else if (ticket_type == "exit") {
                  statusCode = await exit_button_pressed();
                  display_further_status(statusCode, "pending_exit");
                }

                // Navigator.of(context).pop();
              },
            ),
            // If one press the No button of the popup
            new TextButton(
              child: new Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // When the value is "in", that means you should show the person exit button

  // This is called when we press entry button
  Future<int> enter_button_pressed() async {
    String current_user_email = LoggedInDetails.getEmail();
    databaseInterface db = new databaseInterface();
    String location_local = widget.location;
    String date_time = DateTime.now().toString();
    // DateTime now = DateTime.now();
    // String data_time = DateFormat('kk:mm:ss\n dd-MM-yyyy').toString();
    String ticket_type = "enter";
    // Insert into Guard Ticket Table, a ticket of type "enter". This will also update the status of person as pending_entry
    int statusCode;
    if (widget.pre_approval_required) {
      statusCode = await db.insert_in_guard_ticket_table(
          current_user_email,
          location_local,
          date_time,
          ticket_type,
          choosen_authority_ticket,
          "NA");
      databaseInterface.get_guard_notifications(
          current_user_email, location_local, ticket_type);
    } else {
      statusCode = await db.insert_in_guard_ticket_table(
          current_user_email, location_local, date_time, ticket_type, "", "NA");
      databaseInterface.get_guard_notifications(
          current_user_email, location_local, ticket_type);
    }
    return statusCode;
  }

  // This is called when we press exit button
  Future<int> exit_button_pressed() async {
    String current_user_email = LoggedInDetails.getEmail();
    databaseInterface db = new databaseInterface();
    String location_local = widget.location;
    String data_time = DateTime.now().toString();
    String ticket_type = "exit";
    String destinationAddress = _destinationAddressController.text;

    print("location local=${location_local}");

    int statusCode;
    // Insert into Guard Ticket Table, a ticket of type "Exit". This will also update the status of person as pending_exit
    if (widget.pre_approval_required) {
      statusCode = await db.insert_in_guard_ticket_table(
          current_user_email,
          location_local,
          data_time,
          ticket_type,
          choosen_authority_ticket,
          destinationAddress);
      databaseInterface.get_guard_notifications(
          current_user_email, location_local, ticket_type);
    } else {
      statusCode = await db.insert_in_guard_ticket_table(current_user_email,
          location_local, data_time, ticket_type, "", destinationAddress);
      databaseInterface.get_guard_notifications(
          current_user_email, location_local, ticket_type);
    }
    return statusCode;
  }

  // change_pending() {
  //   setState(() {
  //     if (in_or_out == "pending_entry") {
  //       in_or_out = "in";
  //     } else if (in_or_out == "pending_exit") {
  //       in_or_out = "out";
  //     }
  //   });
  // }
}

// Displays the checked out image
class StatusOUT extends StatelessWidget {
  const StatusOUT({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      padding: const EdgeInsets.only(top: 15),
      // padding: const EdgeInsets.all(80),

      // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.blueAccent),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        children: [
          Center(
            child: Text(
              "Status : Out",
              textAlign: TextAlign.center,
              style: GoogleFonts.mPlusRounded1c(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Displays the checked in image
class StatusIN extends StatelessWidget {
  const StatusIN({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      padding: const EdgeInsets.only(top: 15),
      // padding: const EdgeInsets.all(80),

      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.blueAccent),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        children: [
          Center(
            child: Text(
              "Status : In",
              textAlign: TextAlign.center,
              style: GoogleFonts.mPlusRounded1c(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPendingEntry extends StatelessWidget {
  const StatusPendingEntry({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      padding: const EdgeInsets.only(top: 15),

      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.blueAccent),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Status : Pending Entry",
            textAlign: TextAlign.center,
            style: GoogleFonts.mPlusRounded1c(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPendingExit extends StatelessWidget {
  const StatusPendingExit({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      padding: const EdgeInsets.only(top: 15),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.blueAccent),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Status : Pending Exit",
            textAlign: TextAlign.center,
            style: GoogleFonts.mPlusRounded1c(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}

class EnterButton extends StatelessWidget {
  const EnterButton(
      {super.key, required this.enter_function, required this.enter_message});
  final void Function(String) enter_function;
  final String enter_message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            //color: Colors.green,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // ignore: prefer_const_literals_to_create_immutables
                    colors: [
                      Color.fromRGBO(255, 143, 158, 1),
                      Color.fromRGBO(255, 188, 143, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    )
                  ]),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)))),
                onPressed: () {
                  // this.enter_function("enter");
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 100,
                    child: Image.asset("assets/images/enter_button.png"),
                  ),
                ),
              ),
            ),
          ),
          Text(
            this.enter_message,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ExitButton extends StatelessWidget {
  const ExitButton(
      {super.key, required this.exit_function, required this.exit_message});
  final void Function(String) exit_function;
  final String exit_message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color.fromRGBO(255, 143, 158, 1),
                      Color.fromRGBO(255, 188, 143, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    )
                  ]),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)))),
                onPressed: () {
                  // this.exit_function("exit");
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 100,
                    child: Image.asset("assets/images/exit_button.jpeg"),
                  ),
                ),
              ),
            ),
          ),
          Text(
            this.exit_message,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
