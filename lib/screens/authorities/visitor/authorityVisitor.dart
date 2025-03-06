// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/authorities/visitor/past_authority_visitor_ticket_table.dart';
import 'package:my_gate_app/screens/authorities/visitor/pending_authority_visitor_ticket_table.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:my_gate_app/screens/authorities/pending_authority_ticket_table.dart';
// import 'package:my_gate_app/screens/authorities/stream_authority_ticket_table.dart';
// import 'package:my_gate_app/screens/profile2/authority_profile/authority_edit_profile_page.dart';
// import 'package:my_gate_app/screens/profile2/authority_profile/authority_profile_page.dart';
// import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
// import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';

class AuthorityVisitor extends StatefulWidget {
  const AuthorityVisitor({super.key});

  @override
  State<AuthorityVisitor> createState() => _AuthorityVisitorState();
}
enum Status { pending, past }

class _AuthorityVisitorState extends State<AuthorityVisitor>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  List<ResultObj> tickets = [];
  Status _ticket = Status.pending;
  void _toggleTicket(Status input) {
    if (input != _ticket) {
      setState(() {
        _ticket = input;
      });
    }
  }


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
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Color(0xffFCC150),
            title: Text(
              "Visitor Tickets",
              style: GoogleFonts.mPlusRounded1c(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: MediaQuery.of(context).size.width * 0.085,
              ),
            ),
            // actions: [
            //   PopupMenuButton<MenuItem>(
            //     onSelected: (item) => onSelected(context, item),
            //     itemBuilder: (context) => [
            //       ...MenuItems.itemsFirst.map(buildItem).toList(),
            //       PopupMenuDivider(),
            //       ...MenuItems.itemsSecond.map(buildItem).toList(),
            //     ],
            //   ),
            // ],
            centerTitle: true,
            // bottom: TabBar(
            //   controller: controller,
            //   indicator: BoxDecoration(
            //     color: Colors.white.withOpacity(0.5),
            //     borderRadius: BorderRadius.circular(
            //         10.0), // Set the border radius for rounded corners
            //   ),
            //   // ignore: prefer_const_literals_to_create_immutables
            //   tabs: [
            //     Tab(
            //         // child: Text('Pending\nTickets', style: TextStyle(color: Colors.green),),
            //         text: 'Pending\n Tickets',
            //         icon: Icon(Icons.pending_actions)),
            //     Tab(
            //       text: 'Past\n Tickets',
            //       icon: Icon(Icons.approval),
            //     ),
            //   ],
            // ),
          ),
          // body: TabBarView(
          //   controller: controller,
          //   // ignore: prefer_const_literals_to_create_immutables
          //   children: [
          //     PendingAuthorityVisitorTicketTable(),
          //     PastAuthorityVisitorTicketTable(),
          //     // PendingAuthorityTicketTable(),
          //     // StreamAuthorityTicketTable(
          //     //   is_approved: "Approved",
          //     //   image_path: 'assets/images/approved.jpg',
          //     // ),
          //     // StreamAuthorityTicketTable(
          //     //   is_approved: "Rejected",
          //     //   image_path: 'assets/images/rejected.jpg',
          //     // ),
          //   ],
          // ),
          backgroundColor: Color(0xffFFF0D2),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.07,
                      // ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.29,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: ElevatedButton(
                          onPressed: () {
                            _toggleTicket(Status.pending);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_ticket == Status.pending)
                                ? Colors.grey[800]
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Adjust the radius as needed
                            ),
                          ),
                          child: Text(
                              "Pending",

                              style:GoogleFonts.mPlusRounded1c(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white
                              )

                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.32,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: ElevatedButton(
                          onPressed: () {
                            _toggleTicket(Status.past);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_ticket == Status.past)
                                ? Colors.grey[800]
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Adjust the radius as needed
                            ),
                          ),
                          child: Text(
                            "Past",

                            style:GoogleFonts.mPlusRounded1c(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),


                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Your other widgets...
                        SizedBox(
                          // Set constraints for the SizedBox
                          height: MediaQuery.of(context).size.height,
                          child: _ticket == Status.pending
                              ? PendingAuthorityVisitorTicketTable()
                              :PastAuthorityVisitorTicketTable(),
                        ),
                      ],
                    ),
                  ),
                  // Add other content of the body below the row
                ],
              ),
            ),
          ),

        ),
      );
}
