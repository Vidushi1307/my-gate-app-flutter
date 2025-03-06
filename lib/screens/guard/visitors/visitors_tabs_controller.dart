// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/visitors/oldVisitorsSearch.dart';
import 'package:my_gate_app/screens/guard/visitors/oldVisitorsSearchStudents.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorsTabs extends StatefulWidget {
  const VisitorsTabs({
    super.key,
    required this.username,
    required this.phonenumber,
    this.userid,
  });
  final String username;
  final String phonenumber;
  final int? userid;

  @override
  State<VisitorsTabs> createState() => _VisitorsTabsState();
}

class _VisitorsTabsState extends State<VisitorsTabs>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  List<ResultObj> tickets = [];

  // The initState and dispose state are required for adding the tabs
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 180, 180, 180),

            iconTheme: IconThemeData(color: Colors.black),
            flexibleSpace: Container(
                decoration: BoxDecoration(
              color: hexToColor(guardColors[0]),
            )),
            title: Text(
              "Enter Details",
              style: GoogleFonts.mPlusRounded1c(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    // Color.fromARGB(255, 0, 0, 0),
                    Colors.black,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // backgroundColor: Color.fromARGB(255, 203, 202, 202),

            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Colors.black,
                ),
              ),
              labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w800),
              unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w800),

              controller: controller,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              
              tabs: const [
                Tab(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center icon and text horizontally
                      children: [
                        Icon(Icons.pending_actions, color: Colors.black),
                        SizedBox(
                            width: 10), // Adjust the width between icon and text
                        Text(
                          'Student',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center icon and text horizontally
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        SizedBox(
                            width: 8), // Adjust the width between icon and text
                        Text(
                          'Authority',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: controller,
            children: [
              oldVisitorSeacrchStudent(
                  username: widget.username, phonenumber: widget.phonenumber),
              oldVisitorSeacrch(
                  username: widget.username, phonenumber: widget.phonenumber),
            ],
          ),
        ),
      );
}
