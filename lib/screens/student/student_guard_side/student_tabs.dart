// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/student/student_guard_side/stream_student_status.dart';
import 'package:my_gate_app/screens/student/student_guard_side/stream_student_ticket_table.dart';

// This file calls EnterLocation in the first tab and GeneralStudentTicketPage in the second tab

class StudentTabs extends StatefulWidget {
  const StudentTabs({
    super.key,
    required this.location,
    required this.pre_approval_required,
  });
  final String location;
  final bool pre_approval_required;

  @override
  State<StudentTabs> createState() => _StudentTabsState();
}

class _StudentTabsState extends State<StudentTabs>
    with SingleTickerProviderStateMixin {
  late TabController controller;

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
            backgroundColor: Colors.white,
            elevation: 8,
            title: Text(
              widget.location,
              style: GoogleFonts.mPlusRounded1c(color: Colors.black,fontWeight: FontWeight.w900),
            ),
            iconTheme: IconThemeData(color: Colors.black),
            centerTitle: true,
            bottom: TabBar(
              controller: controller,

              indicatorSize: TabBarIndicatorSize.tab,

              // indicator: BoxDecoration(
              //   color: Colors.grey.withOpacity(0.5),
              //
              //   borderRadius: BorderRadius.circular(
              //       10.0), // Set the border radius for rounded corners
              // ), // Set the indicator color to white with opacity
              indicator: UnderlineTabIndicator( // Use UnderlineTabIndicator for underline indicator
                borderSide: BorderSide(
                  width: 4, // Set the thickness of the underline
                  color: Colors.black, // Set the color of the underline
                ),
              ),
              labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w800
              ),
              unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w800
              ),
              tabs:  [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(width: 10), // Adjust the width between icon and text
                      Text(
                          'Status',
                        style: GoogleFonts.mPlusRounded1c(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),

                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 10), // Adjust the width between icon and text
                      Text(
                          'History',
                        style: GoogleFonts.mPlusRounded1c(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),

                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            color: Colors.black,
            child: TabBarView(
              controller: controller,
              children: [
                StreamStudentStatus(
                  location: widget.location,
                  pre_approval_required: widget.pre_approval_required,
                ),
                StreamStudentTicketTable(
                  location: widget.location,
                  pre_approval_required: widget.pre_approval_required,
                ),
              ],
            ),
          ),
        ),
      );
}
