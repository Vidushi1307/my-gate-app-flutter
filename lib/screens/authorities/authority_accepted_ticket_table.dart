// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, dead_code
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

// We pass to this class the value of "is_approved" which takes the value "Accepted"|"Rejected"

class AuthorityAcceptedTicketTable extends StatefulWidget {
  const AuthorityAcceptedTicketTable({
    super.key,
    required this.is_approved,
    required this.image_path,
  });
  final String is_approved;
  final String image_path;

  @override
  _AuthorityAcceptedTicketTableState createState() =>
      _AuthorityAcceptedTicketTableState();
}

class _AuthorityAcceptedTicketTableState
    extends State<AuthorityAcceptedTicketTable> {
  List<ResultObj2> tickets = [];
  List<ResultObj2> ticketsFiltered = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;
  String searchQuery = '';
  int selectedIndex = -1;
  List<ResultObj2> selectedTickets_action = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<List<ResultObj2>> get_tickets_for_authority() async {
    String authority_email = LoggedInDetails.getEmail();
    print(widget.is_approved);
    return await databaseInterface.get_tickets_for_authorities(
        authority_email, widget.is_approved);
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

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }

  Future init() async {
    final Bactickets = await get_tickets_for_authority();
    setState(() {
      tickets = Bactickets;
    });
    filterTickets(searchQuery);
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
                DateTime.parse(ticket.date_time).isBefore(
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
                acceptedRejectedStudentList(ticketsFiltered),
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

  Widget acceptedRejectedStudentList(List<ResultObj2> mytickets) {
    print(mytickets);
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
                        // children: <Widget>[
                        //   ListTile(
                        title: Text(
                          mytickets[index].student_name,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        trailing: Icon(
                          Icons
                              .expand_more, // or Icons.expand_less for upward arrow
                          color: Colors
                              .black, // Change the color to your desired color
                        ),
                        // subtitle: Text(mytickets[index]
                        // .date_time_guard
                        // .toString()),
                        //   onTap: () => toggleExpansion(index),
                        // ),

                        // if (isExpanded)
                        children: <Widget>[
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text(
                                        "Authority_message :${tickets[index].authority_message}",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        )),
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
                                          MainAxisAlignment.center,
                                      children: [
                                        Visibility(
                                          visible:
                                              widget.is_approved == "Rejected",
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              selectedTickets_action
                                                  .add(tickets[index]);
                                              await accept_action_tickets_authorities();
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
                                          visible:
                                              widget.is_approved == "Approved",
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              selectedTickets_action
                                                  .add(tickets[index]);
                                              await reject_action_tickets_authorities();
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

                        // ],
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

//   Widget buildDataTable() {
//     // Fields returned from backend [is_approved, ticket_type, date_time, location, email, student_name, authority_message]
//
//     final columns = [
//       'S.No.',
//       'Name',
//       'Location',
//       'Time',
//       'Entry/Exit',
//       'Authority Message'
//     ];
//
//     return DataTable(
//       border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
//       headingRowColor: MaterialStateProperty.all(Colors.orangeAccent),
//       columns: getColumns(columns),
//       rows: getRows(ticketsFiltered),
//     );
//
//     // return Scaffold(
//     //   body: LayoutBuilder(
//     //     builder: (context, constraints) => SingleChildScrollView(
//     //       child: Column(
//     //         children: [
//     //           const Text('My Text'),
//     //           Container(
//     //             alignment: Alignment.topLeft,
//     //             child: ConstrainedBox(
//     //               constraints: BoxConstraints(maxWidth: constraints.maxWidth),
//     //               child: DataTable(
//     //                 headingRowColor: MaterialStateProperty.all(Colors.red[200]),
//     //                 columns: getColumns(columns),
//     //                 rows: getRows(widget.tickets),
//     //               ),
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //     ),
//     //   ),
//     // );
//
//     // return DataTable(
//     //   headingRowColor: MaterialStateProperty.all(Colors.red[200]),
//     //   columns: getColumns(columns),
//     //   rows: getRows(widget.tickets),
//     // );
//   }
//
//   List<DataColumn> getColumns(List<String> columns) => columns
//       .map((String column) => DataColumn(
//             // label:  Flexible(
//             //   child:Text(column,style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
//             // )
//
//             // label: ConstrainedBox(
//             //   constraints: BoxConstraints(
//             //     maxWidth: 20,
//             //     minWidth: 20,
//             //   ),
//             //   child: Flexible(
//             //       child:Text(column,style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)),
//             // ),
//             label: Text(
//               column,
//               style:
//                   TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//             ),
//           ))
//       .toList();
//
//   List<DataRow> getRows(List<ResultObj2> tickets) {
//     List<DataRow> row_list = [];
//     for (int index = 0; index < tickets.length; index++) {
//       var ticket = tickets[index];
//       row_list.add(DataRow(
//         color: MaterialStateProperty.resolveWith<Color?>(
//             (Set<MaterialState> states) {
//           // All rows will have the same selected color.
//           if (states.contains(MaterialState.selected)) {
//             return Theme.of(context).colorScheme.primary.withOpacity(0.08);
//           }
//           // Even rows will have a grey color.
//           if (index.isEven) {
//             return Colors.grey.withOpacity(0.3);
//           }
//           return null; // Use default value for other states and odd rows.
//         }),
//         // final columns = ['S.No.', 'Student Name', 'Time Generated', 'Entry/Exit', 'Authority Status'];
//
//         // final columns = ['S.No.', 'Student Name', 'Location', 'Time Generated', 'Entry/Exit', 'Authority Message'];
//         cells: [
//           DataCell(
//             Text(
//               (index + 1).toString(),
//               style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//             ),
//           ),
//           DataCell(
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           ProfilePage(email: ticket.email, isEditable: false)),
//                 );
//               },
//               child: Text(
//                 ticket.student_name.toString(),
//                 style: TextStyle(color: Colors.lightBlueAccent),
//               ),
//             ),
//           ),
//           // DataCell(Text(ticket.student_name.toString())),
//           DataCell(Text(
//             ticket.location.toString(),
//             style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//           )),
//           DataCell(Text(
//             "    ${((ticket.date_time.split("T").last)
//                         .split(".")[0]
//                         .split(":")
//                         .sublist(0, 2))
//                     .join(":")}\n${ticket.date_time.split("T")[0]}",
//             style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//           )),
//           DataCell(Text(
//             ticket.ticket_type.toString(),
//             style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//           )),
//           DataCell(Text(
//             ticket.authority_message.toString(),
//             style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//           )),
//         ],
//       ));
//     }
//     return row_list;
//   }
}
