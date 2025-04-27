// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart'; // Adjusted import path
import 'package:my_gate_app/image_paths.dart' as image_paths;
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/guard/current_students_page.dart'; 
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
import 'package:my_gate_app/screens/guard/CS_block_stats.dart';

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
//    notificationCount = await databaseInterface
//        .return_total_notification_count_guard(LoggedInDetails.getEmail());
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

  void _viewCurrentStudents(String locationName) async {
    final students = await databaseInterface.getCurrentStudents(locationName);

    print(students);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentStudentsPage(
          locationName: locationName,
          students: students,
        ),
      ),
    );
  }

  

    void _markLocationAsEmpty(BuildContext context,String locationName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm",
            style: GoogleFonts.poppins(color: Colors.red),
          ),
          content: Text(
            "Mark $locationName as empty?",
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Confirm",
                style: GoogleFonts.poppins(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await databaseInterface.markLocationEmpty(locationName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "$locationName marked as empty"
                : "Failed to mark location",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: success ? hexToColor(guardColors[2]) : Colors.red,
        ),
      );
    }
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
    {"name": "Lab 102", "image": image_paths.cs_lab},
    {"name": "Lab 202", "image": image_paths.cs_lab},
    {"name": "Lab 203", "image": image_paths.cs_lab},
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
          color: Colors.black, // Set the container's color to transparent
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        
        child: Container(
          height: 190, // Increased height
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: RadialGradient(
              center: Alignment.center, // Center of the gradient
              radius: 1.0, // Extends to full width/height of the container
              colors: [
                Color(0xFFE6F4FF), // Very light blue (inner color)
                Color.fromARGB(255, 189, 239,
                    251), // Slightly darker light blue (outer color)
              ],
              stops: [0.0, 1.0], // Smooth transition from center to edge
            ),
            
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
  children: [
    Expanded(
      flex: 2, // Text takes 2/3 of space
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button Row
            Column(
              children: [
      
                ElevatedButton.icon(
                  onPressed: () {
                    // Add your onPressed functionality
                    _markLocationAsEmpty(context,locationName);
                  },
                  icon: Icon(Icons.cleaning_services, size: 16,color:Colors.black),
                  label: Text(
                    "Mark Empty",
                    style: GoogleFonts.poppins(fontSize: 12,color:Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                
                SizedBox(height: 1), // Space between buttons
                
                // View Students Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Add your onPressed functionality
                    _viewCurrentStudents(locationName);
                  },
                  icon: Icon(Icons.people_alt, size: 16, color:Colors.black),
                  label: Text(
                    "View Students",
                    style: GoogleFonts.poppins(fontSize: 12, color:Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            
            Spacer(), // Pushes the location name to bottom
            
            Text(
              locationName,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
    Expanded(
                
                flex: 2,
                child: Container(
                  margin:
                      EdgeInsets.all(5), // Space outside container (optional)
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(12)),
                    color: Colors.transparent, // Optional background
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(12)),
                    child: Container(
                      padding:
                          EdgeInsets.all(8), // Space inside, around the image
                      color: Colors.white
                          .withOpacity(0.1), // Optional inner background
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit
                            .contain, // Changed from 'cover' to respect boundaries
                      ),
                    ),
                  ),
                ),
              ),
    // Your image Expanded widget goes here
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
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 35.0, bottom: 35.0),
          child: Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cur_guard.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          // color: Color.fromARGB(221, 255, 255, 255),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,

                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              SizedBox(
                height: kToolbarHeight,
            //    child: IconButton(
                //  icon: Icon(
                //    Icons.notifications,
                //    color: Colors.black,
                //  ),
                //  onPressed: () async {
//                    List<List<String>> messages = await databaseInterface
//                        .fetch_notification_guard(LoggedInDetails.getEmail());

                    // print(messages);
                //    print("messages printed in page");
                    // print(messages);

                    // await databaseInterface
                    //     .mark_stakeholder_notification_as_false(
                    //         LoggedInDetails.getEmail());
                //    Navigator.push(
                 //       context,
                 //       MaterialPageRoute(
                 //           builder: (context) => NotificationsPage(
                 //                 notificationCount: notificationCount,
                 //               )));
                 // },
             //   ),
              ),
           /*   StreamBuilder<int>(
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
              )*/
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
              PopupMenuDivider(),
              ...MenuItems.itemsFifth.map(buildItem),
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
              // gradient: LinearGradient(
              //   colors: [
              //     const Color(0xFFFFFFFF),
              //     const Color(0xFFF3E8FF),
              //     // const Color(0xFFD6B4FC),

              //   ], // Start and end colors of the gradient
              //   begin: Alignment.topLeft, // Gradient start point
              //   end: Alignment.bottomRight, // Gradient end point
              //   stops: [0.0, 1.0], // Control where each color starts
              // ),
              color: Colors.black,
            ),
            child: Column(
              // add Column
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.width * 0.1),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 65, 65, 67),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    // Changed from Column to Row
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side content (your existing text and icon)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bar_chart,
                                    color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Stats",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 80),
                            Text(
                              "CS Block",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 0.5),
                            // Add any additional text or metrics here
                            Text(
                              "Weekly Usage",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right side (chart)
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 160, // Adjust height as needed
                          padding: EdgeInsets.only(left: 8),
                          child:
                              CSBlockChart(), // The chart widget we created earlier
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Small info cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Today's Students Card
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 71, 71, 72),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: databaseInterface.getCSBlockDailyUsage(),
                          builder: (context, snapshot) {
                            int studentCount = 0;
                            if (snapshot.hasData &&
                                snapshot.data!['days'].isNotEmpty) {
                              studentCount =
                                  snapshot.data!['days'][6]['student_count'];
                              print(snapshot.data!['days'][0]);
                            }

                            return Column(
                              children: [
                                Icon(Icons.people_alt,
                                    color: Colors.white, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  "$studentCount Students",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Hours Used Today Card
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 65, 65, 67),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: databaseInterface.getCSBlockDailyUsage(),
                          builder: (context, snapshot) {
                            double hoursUsed = 0.0;
                            if (snapshot.hasData &&
                                snapshot.data!['days'].isNotEmpty) {
                              // You'll need to modify your backend to also return hours data
                              // This is just a placeholder calculation
                              hoursUsed = snapshot.data!['days'][6]
                                      ['student_count'] *
                                  1.5;
                            }

                            return Column(
                              children: [
                                Icon(Icons.access_time,
                                    color: Colors.white, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  "${hoursUsed.toStringAsFixed(1)} Hours",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Individual labs",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...locations
                          .map((location) => _buildLocationCard(
                              context, location["name"]!, location["image"]!))
                          .toList(),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.08),
                // Row(
                //   children: [
                //     SizedBox(
                //       width: MediaQuery.of(context).size.width * 0.05,
                //     ),
                //     MaterialButton(
                //       onPressed: () {
                //         generateQRButton();
                //       },
                //       padding: EdgeInsets.all(0.0),
                //       child: Ink(
                //         decoration: BoxDecoration(
                //           color: Colors.black,
                //           borderRadius: BorderRadius.circular(10.0),
                //         ),
                //         child: Container(
                //           constraints: BoxConstraints(
                //               maxWidth: MediaQuery.of(context).size.width * 0.9,
                //               minHeight: 70.0),
                //           alignment: Alignment.center,
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               SizedBox(width: 12),
                //               Text(
                //                 "Generate Exit QR",
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                     color: Colors.white,
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 20),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                
                SizedBox(height: 20),

                // RaisedButton(onPressed: () {}, child: Text('Raise Ticket for Authorities'),), // your button beneath text
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
         
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 65, 65, 67),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Select All Button
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Colors.white, size: 35),
                  onPressed: generateQRButton,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white, size: 35),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutUsPage(),
                      ),
                    );
                  },
                ),
                // Home Button
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 35),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EntryExit(guard_location: "CS Block")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white, size: 35),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => (GuardProfilePage(email: LoggedInDetails.getEmail())),
                      ),
                    );
                  },
                ),
              IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 35),
                  onPressed: () {
                    Navigator.of(context).pop(); // pop the current page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
                  },
                ),
                // Sort Button
                
              ],
            ),
          ),
        ),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: item.color),
            const SizedBox(width: 12),
            Text(
              item.text,
              style: TextStyle(
                color: item.color,
              )
            ),
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
      case MenuItems.itemDeleteAccount:
        // Show confirmation dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
                'Are you sure you want to permanently delete your account? '
                'This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // No button
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _deleteAccount(context); // Call your delete function
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.red), // Make "Yes" red for emphasis
                ),
              ),
            ],
          ),
        );
       break;
    }
  }
  
  Future<void> _deleteAccount(BuildContext context) async {
    // Store navigator references BEFORE async operations
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final mainNavigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Deleting account..."),
            ],
          ),
        ),
      ),
    );

    try {
      print("Sending delete request");
      await databaseInterface.delete_guard(LoggedInDetails.getEmail());
      LoggedInDetails.setEmail('');
      // Execute navigation in next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("Dismissing dialog and navigating");
        rootNavigator.pop(); // Dismiss dialog
        mainNavigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      });

    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("Handling error: $e");
        if (rootNavigator.canPop()) rootNavigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
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
