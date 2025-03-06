// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/guard_profile/guard_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:permission_handler/permission_handler.dart';
import 'guard_tabs.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';
import 'package:qrscan/qrscan.dart' as scanner;
// import 'package:mobile_scanner/mobile_scanner.dart' as scanner;
import 'package:my_gate_app/screens/profile2/validification_page.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/guard/visitors/selectVisitor.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/screens/guard/visitors/inviteeValidationPage.dart';

class EntryExit extends StatefulWidget {
  const EntryExit({
    super.key,
    required this.guard_location,
  });
  final String guard_location;

  @override
  State<EntryExit> createState() => _EntryExitState();
}

class _EntryExitState extends State<EntryExit> {
  String welcome_message = "Welcome";
  int notificationCount = /* databaseInterface.return_total_notification_count_guard(LoggedInDetails.getEmail()) */
      0;
  GuardUser cur_guard = UserPreferences.myGuardUser;

  Future<void> get_welcome_message() async {
    String welcome_message_local =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());
    notificationCount = await databaseInterface
        .return_total_notification_count_guard(LoggedInDetails.getEmail());
    // getting the details of the guard
    databaseInterface db = databaseInterface();
    GuardUser result = await db.get_guard_by_email(LoggedInDetails.getEmail());
    print("result obj image path${result.imagePath}");
    print("welcome_message_local :$welcome_message_local");
    print("result :${result.name}");
    setState(() {
      welcome_message = welcome_message_local;
      cur_guard = result;
    });
  }

  Future<String?> _qrScanner() async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isGranted) {
      String? qrdata = await scanner.scan();
      return qrdata;
    } else {
      var isGrant = await Permission.camera.request();
      if (isGrant.isGranted) {
        String? qrdata = await scanner.scan();
        return qrdata;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 253, 253, 255),
      appBar: AppBar(
        backgroundColor: hexToColor(guardColors[0]),
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 35.0, bottom: 35.0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  height: MediaQuery.of(context).size.width * 0.07,
                  child: ClipOval(
                    child: Image(
                      image: NetworkImage(cur_guard.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.022),
                      Text(
                        'Welcome',
                        style: GoogleFonts.lato(
                          // color: Color.fromARGB(221, 255, 255, 255),
                          color: Color(0xFF636060),
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                      Text(
                        cur_guard.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          // color: Color.fromARGB(221, 255, 255, 255),
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.040,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    List<List<String>> messages = await databaseInterface
                        .fetch_notification_guard(LoggedInDetails.getEmail());

                    // print(messages);
                    print("messages printed in page");
                    print(messages);

                    // await databaseInterface
                    //     .mark_stakeholder_notification_as_false(
                    //         LoggedInDetails.getEmail());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage(
                                  notificationCount: notificationCount,
                                )));
                  },
                ),
              ),
              StreamBuilder<int>(
                stream: databaseInterface
                    .get_notification_count_stream(LoggedInDetails.getEmail()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int notificationCount = snapshot.data ?? 0;
                    return Positioned(
                      right: 0,
                      top: 10,
                      child: notificationCount > 0
                          ? Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            icon: Icon(Icons.menu, color: Colors.black),
            itemBuilder: (context) => [
              ...MenuItems.itemsFirst.map(buildItem),
              PopupMenuDivider(),
              ...MenuItems.itemsThird.map(buildItem),
              PopupMenuDivider(),
              ...MenuItems.itemsSecond.map(buildItem),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Container(
            decoration: BoxDecoration(
              // image: DecorationImage(
              // image: AssetImage("assets/images/bulb.jpg"),
              // fit: BoxFit.cover,
              color: Colors.white,
            ),
            child: Column(
              // add Column
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Image.asset('assets/images/enter_exit.webp'),
                SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                ImageWithText(
                  imagePath: 'assets/new_images/main_gate.jpeg',
                  imageHeight: MediaQuery.of(context).size.width * 0.60,
                  imageWidth: MediaQuery.of(context).size.width * 0.70,
                  textContent: "Main Gate",
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        String? qrdata = await _qrScanner();
                        if (qrdata != null) {
                          // Do something with qrdata
                          // print("qrdata bhai=${qrdata}");
                          Map<String, dynamic> qrDataobj_ = jsonDecode(qrdata);

                          Map<String, String> qrDataobj = {};
                          qrDataobj_.forEach((key, value) {
                            qrDataobj[key] = value.toString();
                          });

                          if (qrDataobj['type'] == 'student') {
                            print("email of student${qrDataobj["eml"]}");
                            String email_of_student = qrDataobj["eml"]!;
                            String veh_reg = qrDataobj["v_n"]!;
                            String dest_address = qrDataobj["add"]!;
                            // String entry_no =
                            String ticket_type = qrDataobj["tic_ty"]!;
                            String location_of_student = qrDataobj["s_lc"]!;

                            // String? location_name=qrDataList[4];
                            // print("${}");
                            if (widget.guard_location == location_of_student) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Validification_page(
                                    email: email_of_student,
                                    guard_location: widget.guard_location,
                                    vehicle_reg: veh_reg,
                                    ticket_type: ticket_type,
                                    destination_addr: dest_address,
                                    guard_email: LoggedInDetails.getEmail(),
                                    isEditable: false,
                                    student_location: location_of_student,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'You are not authorized for $location_of_student Locations'),
                                  backgroundColor: Colors
                                      .red, // Set the background color to red
                                ),
                              );
                            }
                          } else if (qrDataobj['type'] == 'invited_visitor') {
                            print("hello!");
                            String ticket_id = qrDataobj['ticket_id']!;
                            print("hello!");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InviteeValidationPage(
                                  ticket_id: ticket_id,
                                ),
                              ),
                            );
                            print("bye");
                          }
                        } else {
                          // Handle the case where qrdata is null
                          print("qrdata bhai=$qrdata");
                        }
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[2]),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.42,
                              minHeight: 100.0),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Scan QR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.06,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => selectVisitor(),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[2]),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.42,
                              minHeight: 100.0),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.21),
                                child: Text(
                                  "Add Visitor Ticket",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.08),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuardTabs(
                              location: widget.guard_location,
                              enter_exit: "enter",
                            ),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[2]),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.42,
                              minHeight: 70.0),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_circle_down,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Enter Tickets",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.06,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuardTabs(
                              location: widget.guard_location,
                              enter_exit: "exit",
                            ),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[2]),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.42,
                              minHeight: 70.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_circle_up, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "Exit Tickets",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // RaisedButton(onPressed: () {}, child: Text('Raise Ticket for Authorities'),), // your button beneath text
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(item.icon, size: 20),
            const SizedBox(width: 12),
            Text(item.text),
          ],
        ),
      );

  void onSelected(BuildContext context, MenuItem item) async {
    switch (item) {
      case MenuItems.itemProfile:
        Navigator.of(context).push(
          // MaterialPageRoute(builder: (context) => ProfileController()),
          // MaterialPageRoute(builder: (context) => GuardProfilePage(email: LoggedInDetails.getEmail())),
          MaterialPageRoute(
              builder: (context) =>
                  GuardProfilePage(email: LoggedInDetails.getEmail())),
        );
        break;
      case MenuItems.itemLogOut:
        LoggedInDetails.setEmail("");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pop(); // pop the current page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
        break;
      case MenuItems.itemAboutUs:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        );
        break;
    }
  }
}

class ImageWithText extends StatelessWidget {
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final double borderRadius;
  final String textContent;

  const ImageWithText({
    super.key,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    this.borderRadius = 15,
    required this.textContent,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imageWidth, // Adjust the width according to your requirement
      height: imageHeight, // Adjust the height according to your requirement
      child: Stack(
        children: [
          SizedBox(
            // constraints: BoxConstraints(width:this.imageWidth),
            width: imageWidth,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 10, // Adjust the left position of the text
            bottom: 10, // Adjust the bottom position of the text
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: Colors.black.withOpacity(0.5),
                // borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: Text(
                textContent,
                style: GoogleFonts.mPlusRounded1c(
                  // color: Color.fromARGB(221, 255, 255, 255),
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
