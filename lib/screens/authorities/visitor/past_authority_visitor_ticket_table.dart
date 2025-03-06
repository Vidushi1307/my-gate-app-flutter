// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/profile2/visitor_profile/visitor_profile_page.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';

class PastAuthorityVisitorTicketTable extends StatefulWidget {
  const PastAuthorityVisitorTicketTable({super.key});

  @override
  State<PastAuthorityVisitorTicketTable> createState() =>
      _PastAuthorityVisitorTicketTableState();
}

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return Colors.cyanAccent[100] as Color;
}

class _PastAuthorityVisitorTicketTableState
    extends State<PastAuthorityVisitorTicketTable> {
  List<ResultObj4> tickets_visitors = [];
  List<ResultObj4> filtered_tickets_visitors = [];
  String searchQuery = '';
  bool isFieldEmpty = true;
  final FocusNode _focusNode = FocusNode();
  List<String> list_of_persons = [];

  String chosen_visitor_name = "None";
  String chosen_visitor_mobile_no = "None";

  List<Color?> inkColors = [
    Colors.orangeAccent[100],
    getColorFromHex('f5a6ff'),
    getColorFromHex('f7f554'),
    getColorFromHex('34ebc0'),
    Colors.lightGreenAccent[200],
    getColorFromHex('62de72'),
  ];

  void filterTickets(String query) {
    if (query.isEmpty) {
      filtered_tickets_visitors = tickets_visitors;
    } else {
      filtered_tickets_visitors = tickets_visitors
          .where((ticket) =>
              ticket.visitor_name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
      filterTickets(searchQuery);
    });
  }

  @override
  void initState() {
    super.initState();
    // init();
    filtered_tickets_visitors.add(ResultObj4.constructor1(
      'Visitor 1',
      '123456789',
      'Status 1',
      'Car 1',
      'Authority 1',
      'authority@example.com',
      'Designation 1',
      'Purpose 1',
      'Status 1',
      'Message 1',
      '2024-03-15 12:00:00',
      '2024-03-15 12:00:00',
      '2024-03-15 12:00:00',
      '2024-03-15 12:00:00',
      'Guard Status 1',
      'Ticket Type 1',
      1,
      'Duration 1',
      'Additional 1',
    ));
  }

  Future<List<ResultObj4>> get_past_visitor_tickets_for_authorities() async {
    return await databaseInterface
        .get_past_visitor_tickets_for_authorities(LoggedInDetails.getEmail());
  }

  List<String> segregrateTickettickets_visitors(List<String> allTickets) {
    List<String> ans = [];

    for (var element in allTickets) {
      var list = element.split("\n");
      ans.add(list[0]);
    }

    return ans;
  }

  Future init() async {
    // ignore: unused_local_variable
    var tickets_local = await get_past_visitor_tickets_for_authorities();

    var list_of_persons_local = await databaseInterface.get_list_of_visitors();

    setState(() {
      tickets_visitors = tickets_local;
      list_of_persons = segregrateTickettickets_visitors(list_of_persons_local);
    });
    filterTickets(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        // Unfocus the TextField when clicked outside
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xffFFF0D2),
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              SizedBox(
                // height: MediaQuery.of(context).size.height / 100,
                width: MediaQuery.of(context).size.width / 1.25,
                child: InputDecorator(
                  isEmpty: isFieldEmpty, // if true, the hint text is shown
                  decoration: InputDecoration(
                    hintText: '    Search by Name',
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 96, 96,
                            96)), // Set the desired color for the hint text
                  ),

                  child: TextField(
                    focusNode: _focusNode,
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      // labelText: "Name",
                      // hintText: "Enter name to filter tickets",
                      // hintStyle: TextStyle(color: Colors.grey),
                      // helperText: "Enter name to filter tickets",
                      // helperStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 36, 0, 108),
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (text) {
                      isFieldEmpty = text.isEmpty;

                      onSearchQueryChanged(text);
                    },
                  ),
                ),
              ),
              Expanded(
                // Logic for Tiles that will be displayed
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    // childAspectRatio: (1.2 / 1),
                    childAspectRatio: 2.5 / 1,
                  ),
                  itemCount: filtered_tickets_visitors.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VisitorProfilePage(
                                      visitorObject:
                                          filtered_tickets_visitors[index],
                                      isEditable: false,
                                    )));
                      },
                      child: Container(
                        height: 10,
                        width: 40,
                        margin: EdgeInsets.all(20),

                        decoration: BoxDecoration(

                          color: Color(0xffEDC882), // Set white background color
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            FittedBox(
                              fit: BoxFit.fill,
                              child: Container(
                                margin: EdgeInsets.all(20),
                                height: 50,
                              ),
                            ),

                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      filtered_tickets_visitors[index].visitor_name,
                                      style: GoogleFonts.mPlusRounded1c(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color:  Colors.black,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      filtered_tickets_visitors[index].mobile_no,
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      '\n${filtered_tickets_visitors[index].date_time_of_ticket_raised.split('T')[0]}',
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:Colors.black,

                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_right,
                              color: Colors.black38,
                              size: 50.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
