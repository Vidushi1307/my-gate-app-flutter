// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, non_constant_identifier_names

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/guard_profile/guard_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:permission_handler/permission_handler.dart';
import 'guard_tabs.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;
import 'package:my_gate_app/screens/profile2/validification_page.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/guard/visitors/selectVisitor.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/screens/guard/visitors/inviteeValidationPage.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;
import 'package:my_gate_app/screens/guard/location_detail_page.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: scanner.MobileScanner(
        onDetect: (capture) {
          final List<scanner.Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            String? scannedValue = barcodes.first.rawValue;
            if (scannedValue != null) {
              scanner.MobileScannerController().stop();
              Navigator.pop(context, scannedValue);
            }
          }
        },
      ),
    );
  }
}

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

  Future<String?> _qrScanner(BuildContext context) async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      var isGrant = await Permission.camera.request();
      if (!isGrant.isGranted) {
        return null;
      }
    }

    if (!context.mounted) return null; // Fix for async gap issue

    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(), // Ensure this class exists
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();
  }

  final List<Map<String, String>> locations = [
    {"name": "Lab 101", "image": image_paths.cs_lab},
    {"name": "Lab 102", "image": image_paths.research_lab},
    {"name": "Lab 202", "image": image_paths.lecture_room},
    {"name": "Lab 203", "image": image_paths.conference_room},
  ];

  void generateQRButton() {
    //to reduce the data length of hte qr data for quick error less scan
    Map<String, String> obj = {
      "tic_ty": "exit",
    };
    String qrData = jsonEncode(obj);
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Show QR code to the student',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Ticket Type: exit',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
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

// Add this helper method outside your build method
  Widget _buildLocationCard(
      BuildContext context, String locationName, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationDetailPage(
                  locationName: locationName, imagePath: imagePath),
            ),
          );
        },
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  locationName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                    child: Image.asset(image_paths.dummy_person),
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
                  imagePath: image_paths.cs_block,
                  imageHeight: MediaQuery.of(context).size.width * 0.60,
                  imageWidth: MediaQuery.of(context).size.width * 0.70,
                  textContent: "CS Block",
                  locationName: "CS Block",
                ),

                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      ...locations
                          .map((location) => _buildLocationCard(
                              context, location["name"]!, location["image"]!))
                          .toList(),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.08),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    MaterialButton(
                      onPressed: () {
                        generateQRButton();
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[2]),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              minHeight: 70.0),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 12),
                              Text(
                                "Generate Exit QR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
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
  final VoidCallback? onTap; // Optional tap callback
  final String? locationName; // For navigation

  const ImageWithText({
    super.key,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    this.borderRadius = 15,
    required this.textContent,
    this.onTap,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            if (locationName != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationDetailPage(
                    locationName: locationName!,
                    imagePath: imagePath,
                  ),
                ),
              );
            }
          },
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: Stack(
          children: [
            SizedBox(
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
              left: 10,
              bottom: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
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
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
