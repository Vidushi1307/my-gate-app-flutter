// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/admin/manage_guard/manage_guards_tabs.dart';
import 'package:my_gate_app/screens/admin/manage_admins/manage_admin_tabs.dart';
import 'package:my_gate_app/screens/admin/manage_locations/manage_location_tabs.dart';
import 'package:my_gate_app/screens/admin/statistics/statistics_tabs.dart';
import 'package:my_gate_app/screens/admin/utils/manage_using_excel/manage_excel_tabs.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/admin_profile/admin_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int notificationCount = 0;
  String welcome_message = "WELCOME";
  final List<Map<String, dynamic>> manageData = [
    {
      "title": "STUDENTS",
      "image": "assets/images/Student.jpeg",
      "navigate": "STUDENTS"
    },
    {
      "title": "GUARDS",
      "image": "assets/images/Guard.jpg",
      "navigate": "GUARDS"
    },
    {
      "title": "ADMINS",
      "image": "assets/images/admin.jpg",
      "navigate": "ADMINS"
    },
    {
      "title": "LOCATIONS",
      "image": "assets/images/Location.jpg",
      "navigate": "LOCATIONS"
    },
    {
      "title": "HOSTELS",
      "image": "assets/images/Hostel.jpg",
      "navigate": "HOSTELS"
    },
    {
      "title": "AUTHORITIES",
      "image": "assets/images/Authorities.jpg",
      "navigate": "AUTHORITIES"
    },
    {
      "title": "DEPARTMENTS",
      "image": "assets/images/Department.jpg",
      "navigate": "DEPARTMENTS"
    },
    {
      "title": "PROGRAMS",
      "image": "assets/images/Program.png",
      "navigate": "PROGRAMS"
    },
  ];

  Future<void> get_welcome_message() async {
    String welcome_message_local =
    await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());
    // print("welcome_message_local: " + welcome_message_local);
    setState(() {
      welcome_message = welcome_message_local;
    });
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();
    // databaseInterface.getLoctions2().then((result){
    //   setState(() {
    //     entries=result;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: MediaQuery.of(context).size.height * 59 / 800,
            backgroundColor: Color(0xFFD9D9D9),
            title: Column(
              children: [
                Text(
                  'ADMIN HOME',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Text(
                //   welcome_message,
                //   style: TextStyle(
                //     fontSize: 15,
                //     color: Colors.black,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      color: Colors.black,
                      onPressed: () {
                        // Handle notification button press
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationsPage(
                                  notificationCount: 0,
                                )));
                      },
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: notificationCount > 0
                        ? Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : Container(),
                  ),
                ],
              ),
              PopupMenuButton<MenuItem>(
                onSelected: (item) => onSelected(context, item),
                // color: Colors.black,
                iconColor: Colors.black,
                itemBuilder: (context) => [
                  ...MenuItems.itemsFirst.map(buildItem),
                  PopupMenuDivider(),
                  ...MenuItems.itemsSecond.map(buildItem),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(),
              child: Container(
                // height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 27 / 800,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StatisticsTabs()),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 150 / 800,
                        width: MediaQuery.of(context).size.width * 330 / 360,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              20), // Adjust border radius as needed
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.2), // Shadow color
                              spreadRadius: 4, // Spread radius
                              blurRadius: 7, // Blur radius
                              offset: Offset(0, 3), // Offset from the container
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // Background Image or Container with Black Blurring
                              Positioned.fill(
                                child: Image.asset(
                                  "assets/images/Statistics.jpg", // Use your show_image function to provide the image path
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(
                                      0.5), // Adjust opacity as needed
                                ),
                              ),

                              // Text at the Bottom Left with Colored Backdrop
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                        0), // Adjust opacity as needed
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "STATISTICS",
                                    style: GoogleFonts.mPlusRounded1c(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // Arrow Icon at the Bottom Right
                              Positioned(
                                right: 16,
                                bottom: 22,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 36 / 800,
                    ),
                    Text("MANAGE DATA",
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.w600, // Semi-bold
                          color: Colors.black,
                        )),
                    Divider(
                      color: Colors.black,
                      height: 20,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          440 /
                          800, // Adjust height as needed
                      child: ListView.builder(
                        // physics: NeverScrollableScrollPhysics(), // Disable scrolling
                        shrinkWrap: true,
                        itemCount: manageData.length,
                        itemBuilder: (context, index) {
                          // Calculate the height of the image based on the height of the list item
                          double imageHeight =
                              MediaQuery.of(context).size.height * 85 / 800;

                          return InkWell(
                            onTap: () {
                              // Navigate to the desired page based on the 'navigate' property
                              switch (manageData[index]["navigate"]) {
                                case "STUDENTS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageExcelTabs(
                                          appbar_title: "Manage Students",
                                          add_url:
                                          "/files/add_students_from_file",
                                          modify_url:
                                          "/files/add_students_from_file",
                                          delete_url:
                                          "/files/delete_students_from_file\n/files/delete_students_from_file_individual",
                                          entity: "Student",
                                          data_entity: "Student",
                                          column_names: [
                                            "Name",
                                            "Entry No.",
                                            "Email",
                                            "Gender",
                                            "Dept.",
                                            "Degree",
                                            "Hostel",
                                            "Room",
                                            "Year",
                                            "Mobile",
                                          ],
                                        )),
                                  );
                                  break;
                                case "GUARDS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageGuardsTabs(
                                            data_entity: "Guard",
                                            column_names: [
                                              "Name",
                                              "Location",
                                              "Email",
                                            ])),
                                  );
                                  break;
                                case "ADMINS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageAdminTabs(
                                          data_entity: "Admins",
                                          column_names: ["Name", "Email"],
                                        )),
                                  );
                                  break;
                                case "LOCATIONS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageLocationTabs(
                                              data_entity: "Locations",
                                              column_names: [
                                                "Location",
                                                "Parent Location",
                                                "Pre Approval",
                                                "Automatic Exit",
                                              ],
                                            )),
                                  );
                                  break;
                                case "HOSTELS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageExcelTabs(
                                          appbar_title: "Manage Hostels",
                                          add_url:
                                          "/files/add_hostels_from_file",
                                          modify_url:
                                          "/files/add_hostels_from_file",
                                          delete_url:
                                          "/files/delete_hostels_from_file",
                                          entity: "Hostel",
                                          data_entity: "Hostels",
                                          column_names: [
                                            "Hostel Name",
                                          ],
                                        )),
                                  );
                                  break;
                                case "AUTHORITIES":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageExcelTabs(
                                          appbar_title:
                                          "Manage Authorities",
                                          add_url:
                                          "/files/add_authorities_from_file",
                                          modify_url:
                                          "/files/add_authorities_from_file",
                                          delete_url:
                                          "/files/delete_authorities_from_file",
                                          entity: "Authorities",
                                          data_entity: "Authorities",
                                          column_names: [
                                            "Name",
                                            "Designation",
                                            "Email",
                                          ],
                                        )),
                                  );
                                  break;
                                case "DEPARTMENTS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageExcelTabs(
                                          appbar_title:
                                          "Manage Departments",
                                          add_url:
                                          "/files/add_departments_from_file",
                                          modify_url:
                                          "/files/add_departments_from_file",
                                          delete_url:
                                          "/files/delete_departments_from_file",
                                          entity: "Departments",
                                          data_entity: "Departments",
                                          column_names: [
                                            "Department Name",
                                          ],
                                        )),
                                  );
                                  break;
                                case "PROGRAMS":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ManageExcelTabs(
                                          appbar_title: "Manage Programs",
                                          add_url:
                                          "/files/add_programs_from_file",
                                          modify_url:
                                          "/files/add_programs_from_file",
                                          delete_url:
                                          "/files/delete_programs_from_file",
                                          entity: "Programs",
                                          data_entity: "Programs",
                                          column_names: [
                                            "Degree Name",
                                            "Degree Duration",
                                          ],
                                        )),
                                  );
                                  break;
                              // Add cases for other navigation destinations
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    80 /
                                    800,
                                width: MediaQuery.of(context).size.width *
                                    330 /
                                    360,
                                child: Row(
                                  children: [
                                    // Image on the left
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Adjust the value according to your preference
                                      child: Image.asset(
                                        manageData[index]["image"],
                                        height:
                                        imageHeight, // Use the calculated height here
                                        width:
                                        imageHeight, // Maintain aspect ratio
                                        fit: BoxFit
                                            .cover, // This ensures the image fills the rounded corners
                                      ),
                                    ),

                                    SizedBox(width: 20),
                                    // Text on the right
                                    Text(
                                      manageData[index]['title'],
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),


                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 13 / 800,
                    // ),
                  ],
                ),
              ),
            ),
          )),
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
                  AdminProfilePage(email: LoggedInDetails.getEmail())),
        );
        break;
      case MenuItems.itemLogOut:
        LoggedInDetails.setEmail("");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
        break;
    }
  }
}

