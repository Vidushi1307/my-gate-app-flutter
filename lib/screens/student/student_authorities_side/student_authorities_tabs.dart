import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/student/student_authorities_side/generate_preapproval_ticket.dart';
import 'package:my_gate_app/screens/student/student_authorities_side/stream_student_authorities_ticket_table.dart';

// This file calls EnterLocation in the first tab and GeneralStudentTicketPage in the second tab

class StudentAuthoritiesTabs extends StatefulWidget {
  const StudentAuthoritiesTabs({super.key, required this.location});
  final String location;

  @override
  State<StudentAuthoritiesTabs> createState() => _StudentAuthoritiesTabsState();
}

class _StudentAuthoritiesTabsState extends State<StudentAuthoritiesTabs>
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

            backgroundColor: Colors.white, // Set the app bar background color to black
            title: Text(
              widget.location,
              style: GoogleFonts.mPlusRounded1c( color: Colors.black , fontWeight: FontWeight.w900), // Set the title text color to white
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            bottom: TabBar(
              // padding: EdgeInsets.symmetric(vertical: 7),
              controller: controller,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Colors.black,
                ),
              ),
              labelStyle: const TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w800),
              unselectedLabelStyle: TextStyle(fontSize: 16,color: Colors.grey[700],fontWeight: FontWeight.w800),
              tabs:  [

                Tab(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center icon and text horizontally
                      children: [
                        const Icon(Icons.add),
                        const SizedBox(width: 10), // Adjust the width between icon and text
                        Text(
                            'Generate\n  Ticket',
                          style: GoogleFonts.mPlusRounded1c(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center icon and text horizontally
                      children: [
                        const Icon(Icons.history),
                        const SizedBox(width: 10), // Adjust the width between icon and text
                        Text(
                          ' Past\nTickets',
                          style: GoogleFonts.mPlusRounded1c(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
              GeneratePreApprovalTicket(location: widget.location),
              StreamStudentAuthoritiesTicketTable(location: widget.location),
            ],
          ),
        ),
      );
}
