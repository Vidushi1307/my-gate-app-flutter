// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, avoid_print, must_be_immutable
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

class PendingAuthorityTicketTable extends StatefulWidget {
  const PendingAuthorityTicketTable({super.key});

  @override
  _PendingAuthorityTicketTableState createState() =>
      _PendingAuthorityTicketTableState();
}

class _PendingAuthorityTicketTableState
    extends State<PendingAuthorityTicketTable> {
  String ticket_accepted_message = '';
  String ticket_rejected_message = '';

  List<ResultObj2> tickets = [];

  List<ResultObj2> ticketsFiltered = [];
  String searchQuery = '';

  List<ResultObj2> selectedTickets = [];
  List<ResultObj2> selectedTickets_action = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;
  int selectedIndex = -1;

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }

  Future<void> accept_selected_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.accept_selected_tickets_authorities(selectedTickets);
    // print("The status code is " + status_code.toString());
    if (status_code == 200) {
      print("Selected tickets accepted\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("Selected tickets accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (status_code == 201) {
      print("Selected tickets accepted\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("No Tickets Selected!", Colors.orange);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("Failed to accept the tickets\n");
      print("Tell this thing to the authority\n");
      final snackBar =
          get_snack_bar("Failed to accept the tickets", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_selected_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.reject_selected_tickets_authorities(selectedTickets);
    print("The status code is $status_code");
    if (status_code == 200) {
      print("Selected tickets rejected\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("Selected tickets rejected", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (status_code == 201) {
      print("Selected tickets accepted\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("No Tickets Selected!", Colors.orange);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("Failed to accept the tickets\n");
      print("Tell this thing to the authority\n");
      final snackBar =
          get_snack_bar("Failed to reject the tickets", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> accept_action_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.accept_selected_tickets_authorities(selectedTickets_action);
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Failed to accept the ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_action_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.reject_selected_tickets_authorities(selectedTickets_action);
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

  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = tickets
            .where((ticket) =>
                DateTime.parse(ticket.date_time).toLocal().isBefore(
                    DateTime.parse(chosen_end_date).add(Duration(days: 1))) &&
                DateTime.parse(ticket.date_time)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)))
            .toList();
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                ticket.student_name
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.date_time)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)) &&
                DateTime.parse(ticket.date_time).toLocal().isBefore(
                    DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
        print(chosen_end_date);
      }
    } else {
      if (query.isEmpty) {
        ticketsFiltered = tickets;
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                ticket.student_name.toLowerCase().contains(query.toLowerCase()))
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
  void initState() {
    super.initState();
    init();
  }

  Future<List<ResultObj2>> get_pending_tickets_for_authority() async {
    String authority_email = LoggedInDetails.getEmail();
    return await databaseInterface
        .get_pending_tickets_for_authorities(authority_email);
  }

  Future init() async {
    final tickets_local = await get_pending_tickets_for_authority();
    setState(() {
      tickets = tickets_local;
      selectedTickets = [];
      selectedTickets_action = [];
    });
    filterTickets(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    print(tickets.length);
    return Scaffold(
      backgroundColor: Color(0xffFFF0D2),
      body: Column(
        children: [
          Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.73,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5.0),
                border:
                    Border(bottom: BorderSide(color: Colors.black, width: 2.0)),
              ),
              child: TextField(
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 20,
                ),
                onChanged: (text) {
                  print(text);
                  isFieldEmpty = text.isEmpty;

                  onSearchQueryChanged(text);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5.0, 0, 0, 14.0),
                  hintText: 'Search by Student Name',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                    },
                  ),
                  hintStyle: GoogleFonts.lato(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
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

          pendingStudentList(ticketsFiltered),
          // buildSubmit(),
        ],
      ),
    );
  }

  Widget pendingStudentList(List<ResultObj2> mytickets) {
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
                          mytickets[index].student_name,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        children: <Widget>[
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "Student :${tickets[index].student_name}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    Text("Location :${tickets[index].location}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    Text(
                                        "Time :${((tickets[index].date_time.split("T").last).split(".")[0].split(":").sublist(0, 2)).join(":")}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    Text(
                                        "Ticket_type :${tickets[index].ticket_type}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
                                    SizedBox(height: 8),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4, // 80% of screen width
                                      height: 1, // Height of the divider
                                      color: Colors
                                          .black12, // Color of the divider
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Authority_Message: ",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (text) {
                                                setState(() {
                                                  tickets[index]
                                                      .authority_message = text;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    "Enter Authority Message",
                                                hintStyle: TextStyle(
                                                  color: Colors.white54,
                                                ),
                                                border: InputBorder.none,
                                              ),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 5),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8, // 80% of screen width
                                      height: 1, // Height of the divider
                                      color: Colors
                                          .black12, // Color of the divider
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            selectedTickets_action
                                                .add(tickets[index]);
                                            await accept_action_tickets_authorities();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  5), // Adjust the radius as needed
                                            ),
                                          ),
                                          child: Text(
                                            "Accept",
                                            style: GoogleFonts.mPlusRounded1c(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            selectedTickets_action
                                                .add(tickets[index]);
                                            await reject_action_tickets_authorities();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  5), // Adjust the radius as needed
                                            ),
                                          ),
                                          child: Text(
                                            "Reject",
                                            style: GoogleFonts.mPlusRounded1c(
                                              color: Colors.white,
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

  Widget buildDataTable() {
    // Fields returned from backend [is_approved, ticket_type, date_time, location, email, student_name, authority_message]

    final columns = [
      'Student',
      'Location',
      'Time',
      'Entry/Exit',
      'Authority Message',
      'Action'
    ];

    return DataTable(
      onSelectAll: (isSelectedAll) {
        setState(() => selectedTickets = isSelectedAll! ? tickets : []);
        // Utils.showSnackBar(context, 'All Selected: $isSelectedAll');
      },
      border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
      headingRowColor: MaterialStateProperty.all(Colors.orangeAccent),
      columns: getColumns(columns),
      rows: getRows(ticketsFiltered),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(
              column,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ))
      .toList();

  List<DataRow> getRows(List<ResultObj2> tickets) {
    List<DataRow> row_list = [];
    for (int index = 0; index < tickets.length; index++) {
      var ticket = tickets[index];
      row_list.add(DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          // All rows will have the same selected color.
          if (states.contains(MaterialState.selected)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          }
          // Even rows will have a grey color.
          if (index.isEven) {
            return Colors.grey.withOpacity(0.3);
          } else {
            return Color.fromARGB(255, 91, 101, 128).withOpacity(0.3);
          }
          return null; // Use default value for other states and odd rows.
        }),
        selected: selectedTickets.contains(ticket),
        onSelectChanged: (isSelected) => setState(() {
          final isAdding = isSelected != null && isSelected;

          isAdding
              ? selectedTickets.add(ticket)
              : selectedTickets.remove(ticket);
          print(selectedTickets);
        }),

        // final columns = ['S.No.', 'Student Name', 'Location', 'Time Generated', 'Entry/Exit', 'Authority Message'];
        cells: [
          DataCell(
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(email: ticket.email, isEditable: false)),
                );
              },
              child: Text(
                ticket.student_name.toString(),
                style: TextStyle(color: Colors.lightBlueAccent),
              ),
            ),
          ),
          // DataCell(Text(ticket.student_name.toString())),
          DataCell(Text(
            ticket.location.toString(),
            style: TextStyle(color: Colors.black),
          )),
          DataCell(Text(
            "    ${((ticket.date_time.split("T").last).split(".")[0].split(":").sublist(0, 2)).join(":")}\n${ticket.date_time.split("T")[0]}",
            style: TextStyle(color: Colors.black),
          )),
          DataCell(Text(
            ticket.ticket_type.toString(),
            style: TextStyle(color: Colors.black),
          )),
          // DataCell(Text(ticket.authority_message.toString())),
          DataCell(
            TextField(
              onChanged: (text) {
                this.tickets[index].authority_message = text;
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                onPressed: () async {
                  selectedTickets_action.add(ticket);
                  await accept_action_tickets_authorities();
                },
                icon: Icon(
                  // Action Button Tick
                  Icons.check_circle_outlined,
                  color: Colors.green,
                  size: 24.0,
                ),
              ),
              IconButton(
                // Action Button Cross
                onPressed: () async {
                  selectedTickets_action.add(ticket);
                  await reject_action_tickets_authorities();
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 24.0,
                ),
              ),
            ],
          ))
        ],
      ));
    }
    return row_list;
  }
}
