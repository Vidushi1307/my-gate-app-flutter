// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/guard_profile/guard_profile_page.dart';
import 'package:my_gate_app/screens/authorities/authority_tabs.dart';
import 'package:my_gate_app/screens/authorities/visitor/authorityVisitor.dart';
import 'package:my_gate_app/screens/authorities/relatives/stu_relatives.dart';
import 'package:my_gate_app/screens/profile2/authority_profile/authority_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/authorities/location_detail_authority.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/authorities/lab_stats.dart';

class AuthorityMain extends StatefulWidget {
  const AuthorityMain({super.key});
  // final StriK pre_approval_required;

  @override
  State<AuthorityMain> createState() => _AuthorityMainState();
}

final List<Map<String, String>> locations = [
  {"name": "Lab 101", "image": image_paths.cs_lab},
  {"name": "Lab 102", "image": image_paths.research_lab},
  {"name": "Lab 202", "image": image_paths.lecture_room},
  {"name": "Lab 203", "image": image_paths.conference_room},
];

class _AuthorityMainState extends State<AuthorityMain> {
  int notificationCount = 0;
  String welcome_message = "Dr.Ravi Kant";

  var user = UserPreferences.myAuthorityUser;

  late String imagePath;

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? curr_email = LoggedInDetails.getEmail();
    print("Current Email: $curr_email");
    databaseInterface db = databaseInterface();
    // User result = await db.get_student_by_email(curr_email);
    // // print("result obj image path" + result.imagePath);
    // setState(() {
    //   user = result;
    //   imagePath = result.imagePath;
    //   // print("image path inside setstate: " + imagePath);
    // });

    setState(() {
      pic = NetworkImage(imagePath);
    });
    /* print("Gender in yo:"+controller_gender.text); */
  }

  Future<void> get_welcome_message() async {
    String welcome_message_local =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());

    print("welcome_message_local: $welcome_message_local");
    print("studentStatusDB:");
    notificationCount = await databaseInterface
        .return_total_notification_count_guard(LoggedInDetails.getEmail());
    databaseInterface db = databaseInterface();
    AuthorityUser result =
        await db.get_authority_by_email(LoggedInDetails.getEmail());
    setState(() {
      user = result;
      welcome_message = welcome_message_local;
      print("Going here");
    });
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();

    imagePath = UserPreferences.myUser.imagePath;
    pic = NetworkImage(imagePath);

    // print("image path in image widget: " + this.imagePath);
    init();
  }

  @override
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
                        user.name,
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
              ...MenuItems.itemsFourth.map(buildItem),
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
      case MenuItems.itemViewStats:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LabStatsPage()),
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
      await databaseInterface.delete_authority(LoggedInDetails.getEmail());
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
