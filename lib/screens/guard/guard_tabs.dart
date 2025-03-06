// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/ticket_screen.dart';

class GuardTabs extends StatefulWidget {
  const GuardTabs({
    super.key,
    required this.location,
    required this.enter_exit,
  });
  final String location;
  final String enter_exit;

  @override
  State<GuardTabs> createState() => _GuardTabsState();
}

class _GuardTabsState extends State<GuardTabs>
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

  Widget enterExitHeader() {
    if (widget.enter_exit == 'enter') {
      return Text(
        "Enter Tickets",
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        "Exit Tickets",
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(color: hexToColor(guardColors[0])),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // backgroundColor: Color.fromARGB(255, 203, 202, 202),
            title: Column(
              children: [
                // enterExitHeader(),
                Text(
                  widget.location,
                  style: GoogleFonts.mPlusRounded1c(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),

            bottom: TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: hexToColor(guardColors[1]),
                  width:5.0 )
              ),
              // BoxDecoration(
              //   color: hexToColor(guardColors[2]),
              //   borderRadius: BorderRadius.circular(
              //       18.0), // Set the border radius for rounded corners
              // ),
              controller: controller,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.mPlusRounded1c(
                color:
                hexToColor(guardColors[1]),
                // hexToColor(guardColors[2]),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.mPlusRounded1c(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(
                  // icon:
                  // Icon(Icons.approval, color: hexToColor(guardColors[2])),
                  // iconMargin: EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text(
                      'Approved\nTickets',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Tab(
                  // icon: Icon(Icons.cancel, color: Color.fromARGB(255, 0, 0, 0)),
                  // iconMargin: EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text(
                      'Rejected\nTickets',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
          body: 
              TabBarView(
                controller: controller,
                children: [
                  // StreamSelectablePage(location: widget.location,),

                  // SelectablePage(
                  //     location: widget.location, enter_exit: widget.enter_exit),
                  // Present in file pending_guard_ticket_table.dart
                  // GuardTicketTable(location: widget.location, is_approved: "Approved",),
                  // GuardTicketTable(location: widget.location, is_approved: "Rejected",),

                  // StreamGuardTicketTable(
                  //   location: widget.location,
                  //   is_approved: "Approved",
                  //   enter_exit: widget.enter_exit,
                  //   image_path: 'assets/images/approved.jpg',
                  // ),
                  // StreamGuardTicketTable(
                  //     location: widget.location,
                  //     is_approved: "Rejected",
                  //     enter_exit: widget.enter_exit,
                  //     image_path: 'assets/images/rejected.jpg'),

                  TicketScreen(
                    location:widget.location,
                    isApproved:"Approved",
                    enterExit:widget.enter_exit,
                    imagePath: 'assets/images/approved.jpg',
                  ),
                  TicketScreen(
                    location:widget.location,
                    isApproved:"Rejected",
                    enterExit:widget.enter_exit,
                    imagePath: 'assets/images/rejected.jpg',
                  )
                  
                ],
              ),
        ),
      );
}
