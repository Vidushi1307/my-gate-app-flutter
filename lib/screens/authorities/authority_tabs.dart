// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/authorities/pending_authority_ticket_table.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/authorities/authority_rejected_ticket_table.dart';
import 'package:my_gate_app/screens/authorities/authority_accepted_ticket_table.dart';
class AuthorityTabs extends StatefulWidget {
  const AuthorityTabs({super.key});

  @override
  State<AuthorityTabs> createState() => _AuthorityTabsState();
}

enum Status { pending, accepted,rejected }

class _AuthorityTabsState extends State<AuthorityTabs>
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
    controller = TabController(length: 3, vsync: this);
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
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Color(0xffFCC150),
            title: Text(
                "Student Tickets",
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
          ),
          // body: TabBarView(
          //   controller: controller,
          //   // ignore: prefer_const_literals_to_create_immutables
          //   children: [
          //     PendingAuthorityTicketTable(),
          //     StreamAuthorityTicketTable(
          //       is_approved: "Approved",
          //       image_path: 'assets/images/approved.jpg',
          //     ),
          //     StreamAuthorityTicketTable(
          //       is_approved: "Rejected",
          //       image_path: 'assets/images/rejected.jpg',
          //     ),
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
                              ),

            
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.07,
                      // ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.32,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: ElevatedButton(
                          onPressed: () {
                            _toggleTicket(Status.accepted);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_ticket == Status.accepted)
                                ? Colors.grey[800]
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Adjust the radius as needed
                            ),
                          ),
                          child: Text(
                            "Accepted",
            
                            style:GoogleFonts.mPlusRounded1c(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.32,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: ElevatedButton(
                          onPressed: () {
                            _toggleTicket(Status.rejected);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_ticket == Status.rejected)
                                ? Colors.grey[800]
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Adjust the radius as needed
                            ),
                          ),
                          child: Text(
                            "Rejected",
            
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
                              ? PendingAuthorityTicketTable()
                              : _ticket == Status.accepted
                              ?
                          AuthorityAcceptedTicketTable(

                              is_approved: "Approved" ,
                              image_path: 'assets/images/approved.jpg',
                          )
                        // StreamAuthorityTicketTable(
                        //     is_approved: "Approved",
                        //     image_path: 'assets/images/approved.jpg',
                        //   )
                              :
                          AuthorityRejectedTicketTable(

                            is_approved: "Rejected" ,
                            image_path: 'assets/images/rejected.jpg',
                          ),
                          // StreamAuthorityTicketTable(
                          //   is_approved: "Rejected",
                          //   image_path: 'assets/images/rejected.jpg',
                          // ),
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

  // PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
  //       value: item,
  //       child: Row(
  //         children: [
  //           Icon(item.icon, size: 20),
  //           const SizedBox(width: 12),
  //           Text(item.text),
  //         ],
  //       ),
  //     );

  // void onSelected(BuildContext context, MenuItem item) {
  //   switch (item) {
  //     case MenuItems.itemProfile:
  //       Navigator.of(context).push(
  //         // MaterialPageRoute(builder: (context) => ProfileController()),
  //         MaterialPageRoute(
  //             builder: (context) =>
  //                 AuthorityProfilePage(email: LoggedInDetails.getEmail())),
  //       );
  //       break;
  //     case MenuItems.itemLogOut:
  //       LoggedInDetails.setEmail("");
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => AuthScreen()),
  //       );
  //       break;
  //   }
  // }
}
