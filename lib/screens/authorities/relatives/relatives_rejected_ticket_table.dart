// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, dead_code
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

// We pass to this class the value of "is_approved" which takes the value "Accepted"|"Rejected"

class RelativesRejectedTicketTable extends StatefulWidget {
  const RelativesRejectedTicketTable({
    super.key,
    required this.is_approved,
    required this.image_path,
  });
  final String is_approved;
  final String image_path;

  @override
  _RelativesRejectedTicketTableState createState() =>
      _RelativesRejectedTicketTableState();
}

class _RelativesRejectedTicketTableState
    extends State<RelativesRejectedTicketTable> {
  List<StuRelTicket> tickets = [];
  List<StuRelTicket> ticketsFiltered = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;
  String searchQuery = '';
  int selectedIndex = -1;
  List<StuRelTicket> selectedTickets_action = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<List<StuRelTicket>> Get_relatives_ticket_for_authority() async {
    print(widget.is_approved);
    return await databaseInterface.Get_relatives_ticket_for_authority(
        widget.is_approved);
  }

  Future init() async {
    final Bactickets = await Get_relatives_ticket_for_authority();
    setState(() {
      tickets = Bactickets;
    });
    filterTickets(searchQuery);
  }

  Future<void> accept_action_relatives_tickets_authorities(
      String ticket_id) async {
    int status_code = await databaseInterface
        .accept_action_relatives_tickets_authorities(ticket_id);
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Failed to accept the ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_action_relatives_tickets_authorities(
      String ticket_id) async {
    int status_code = await databaseInterface
        .reject_action_relatives_tickets_authorities(ticket_id);
    print("The status code is $status_code");
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket rejected", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Failed to reject the ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }

  //
  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = tickets
            .where((ticket) =>
                DateTime.parse(ticket.visit_date).toLocal().isBefore(
                    DateTime.parse(chosen_end_date).add(Duration(days: 1))) &&
                DateTime.parse(ticket.visit_date)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)))
            .toList();
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                (ticket.studentName?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.visit_date)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)) &&
                DateTime.parse(ticket.visit_date).toLocal().isBefore(
                    DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
        print(chosen_end_date);
      }
    } else {
      if (query.isEmpty) {
        ticketsFiltered = tickets;
      } else {
        ticketsFiltered = tickets
            .where((ticket) => (ticket.studentName?.toLowerCase() ?? '')
                .contains(query.toLowerCase()))
            .toList();
      }
    }
  }

  void onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
      filterTickets(searchQuery);
    });
  }

  void resetFilter(String query) {
    chosen_start_date = DateTime.now().subtract(Duration(days: 1)).toString();
    chosen_end_date = DateTime.now().toString();
    filterTickets(query);
  }

  //
  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: 7)),
    );
    DateTimeRange? selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: initialDateRange,
    );
    if (selectedDateRange != null) {
      setState(() {
        chosen_start_date = selectedDateRange.start.toString();
        chosen_end_date = selectedDateRange.end.toString();
        filterTickets(searchQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color(0xffFFF0D2),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Row(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  Container(
                    // margin: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width * 0.73,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 2.0)),
                    ),
                    // child: TextField(
                    //   style: GoogleFonts.lato(
                    //     color: Colors.black,
                    //     fontSize: 20,
                    //   ),
                    //   onChanged: (text) {
                    //     // isFieldEmpty = text.isEmpty;
                    //     // onSearchQueryChanged(text);
                    //   },
                    //   decoration: InputDecoration(
                    //     contentPadding: EdgeInsets.fromLTRB(5.0, 0, 0, 14.0),
                    //     hintText: 'Search by Name',
                    //     border: InputBorder.none,
                    //     prefixIcon: Icon(Icons.search, color: Colors.black),
                    //     suffixIcon: IconButton(
                    //       padding: EdgeInsets.zero,
                    //       icon: Icon(Icons.clear, color: Colors.black),
                    //       onPressed: () {
                    //         // Clear search field
                    //       },
                    //     ),
                    //     hintStyle: GoogleFonts.lato(
                    //       color: Colors.black87,
                    //       fontSize: 16.0,
                    //       fontWeight: FontWeight.normal,
                    //     ),
                    //   ),
                    // ),
                    child: buildSearchTextField(),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.filter_alt,
                          color: Colors.black87), // Filter icon
                      onPressed: () {
                        enableDateFilter = true;
                        _selectDateRange(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.filter_alt_off,
                          color: Colors.black87), // Filter icon
                      onPressed: () {
                        setState(() {
                          enableDateFilter = !enableDateFilter;
                          resetFilter(searchQuery);
                        });
                      },
                    ),
                  ),
                ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),

                // Expanded(child: ScrollableWidget(child: buildDataTable())),
                acceptedRejectedRelativeList(ticketsFiltered),
              ],
            ),
          ),
        ),
      );

  TextField buildSearchTextField() {
    TextEditingController searchController = TextEditingController();

    // Initialize controller value only if searchQuery is not empty
    if (searchQuery.isNotEmpty) {
      searchController.text = searchQuery;
      searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length));
    }
    print("hello i am here start");
    return TextField(
      controller: searchController,
      style: GoogleFonts.lato(
        color: Colors.black,
        fontSize: 20,
      ),
      onChanged: (text) {
        onSearchQueryChanged(text);
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(5.0, 0, 0, 14.0),
        hintText: 'Search by Student Name',
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: Colors.black),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    searchQuery = '';
                    filterTickets('');
                  });
                },
              )
            : null,
        hintStyle: GoogleFonts.lato(
          color: Colors.black87,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget acceptedRejectedRelativeList(List<StuRelTicket> mytickets) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.67,
        child: ListView.builder(
          itemCount: mytickets.length,
          itemBuilder: (BuildContext context, int index) {
            final bool isExpanded = index == selectedIndex;
            return Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffEDC882),
                        borderRadius: BorderRadius.circular(
                            15), // Adjust the radius as needed
                      ),
                      child: ExpansionTile(
                        title: Text(
                          mytickets[index].studentId,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          '${mytickets[index].studentName}',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        // subtitle: Text(mytickets[index]
                        // .date_time_guard
                        // .toString()),

                        children: <Widget>[
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "InviteeName : ${tickets[index].inviteeName}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 2),
                                    Text(
                                        "InviteeRelationship : ${tickets[index].inviteeRelationship}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 2),
                                    Text(
                                        "InviteeContact : ${tickets[index].inviteeContact}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 2),
                                    Text(
                                        "Visit_Date : ${tickets[index].visit_date}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 2),
                                    Text(
                                        "Durations(In-Days) : ${tickets[index].duration}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 2),
                                    Text("Purpose : ${tickets[index].purpose}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Visibility(
                                          visible: tickets[index].status ==
                                              "Rejected",
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // selectedTickets_action.add(tickets[index]);
                                              await accept_action_relatives_tickets_authorities(
                                                  tickets[index].ticketId);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              "Accept",
                                              style: GoogleFonts.mPlusRounded1c(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: tickets[index].status ==
                                              "Accepted",
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // selectedTickets_action.add(tickets[index]);
                                              await reject_action_relatives_tickets_authorities(
                                                  tickets[index].ticketId);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              "Reject",
                                              style: GoogleFonts.mPlusRounded1c(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }
}
