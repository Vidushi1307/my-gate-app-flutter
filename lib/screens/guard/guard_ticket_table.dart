// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, dead_code
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/utils/authority_message.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/utils/scrollable_widget.dart';

// We pass to this class the value of "is_approved" which takes the value "Accepted"|"Rejected"

class GuardTicketTable extends StatefulWidget {
  GuardTicketTable({
    super.key,
    required this.location,
    required this.is_approved,
    required this.tickets,
    required this.image_path,
    required this.enter_exit,
  });
  final String location;
  final String is_approved;
  final String image_path;
  final String enter_exit;
  List<ResultObj> tickets;

  @override
  _GuardTicketTableState createState() => _GuardTicketTableState();
}

enum SingingCharacter { Students, Visitors }

class _GuardTicketTableState extends State<GuardTicketTable> {
  String searchQuery = '';

  SingingCharacter? _character = SingingCharacter.Students;
  List<ResultObj> tickets = [];
  List<ResultObj> ticketsFiltered = [];
  List<ResultObj4> tickets_visitors = [];
  List<ResultObj4> tickets_visitorsFiltered = [];
  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;
  String Person = "Students";

  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = tickets
            .where((ticket) => DateTime.parse(ticket.date_time).toLocal().isBefore(
                DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                ticket.student_name
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.date_time).toLocal()
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

  Future<List<ResultObj>> get_tickets_for_guard() async {
    // De
    //
    // upon the location and ticket status, fetch the tickets
    // For example fetch all tickets of Main Gate where ticket status is accepted
    return await databaseInterface.get_tickets_for_guard(
        widget.location, widget.is_approved, widget.enter_exit);
  }

  Future<List<ResultObj4>> get_approved_tickets_for_visitors() async {
    return await databaseInterface.return_entry_visitor_approved_ticket(
        widget.location, widget.is_approved, widget.enter_exit);
  }

  Future init() async {
    // tickets = await get_tickets_for_guard();
    late List<ResultObj> tickets_local;
    late List<ResultObj4> tickets_local_2;
    if (Person == 'Students') {
      tickets_local = await get_tickets_for_guard();
    } else {
      tickets_local_2 = await get_approved_tickets_for_visitors();
    }

    setState(() {
      if (Person == 'Students') {
        tickets = tickets_local;
      } else {
        tickets_visitors = tickets_local_2;
      }
      // int len = tickets.length;
      // if(len == 0){
      //   TicketResultObj obj = new TicketResultObj.constructor1();
      //   obj.empty_table_entry(obj);
      //   this.tickets = [];
      //   // this.tickets.add(obj);
      // }else{
      //   this.tickets = tickets;
      // }
    });
    filterTickets(searchQuery);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          body: ScrollableWidget(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(1),
                    child: Text(
                      // "Ticket Table",
                      "",
                      style: GoogleFonts.roboto(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Theme(
                  data: ThemeData.light(),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: RadioListTile<SingingCharacter>(
                          title: const Text(
                            'Students',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          value: SingingCharacter.Students,
                          groupValue: _character,
                          activeColor: Colors.black,
                          onChanged: (SingingCharacter? value) {
                            if (value != null) {
                              setState(() {
                                _character = value;
                                Person = value.name;
                                init();
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: RadioListTile<SingingCharacter>(
                          title: const Text(
                            'Visitors',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          value: SingingCharacter.Visitors,
                          groupValue: _character,
                          activeColor: Colors.black,
                          onChanged: (SingingCharacter? value) {
                            if (value != null) {
                              setState(() {
                                _character = value;
                                Person = value.name;
                                init();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: InputDecorator(
                        isEmpty:
                            isFieldEmpty, // if true, the hint text is shown
                        decoration: InputDecoration(
                          hintText: '    Search by Name',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 96, 96,
                                  96)), // Set the desired color for the hint text
                        ),

                        child: TextField(
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          decoration: InputDecoration(
                            // labelText: "Name",
                            // hintText: "Enter name to filter tickets",
                            // hintStyle: TextStyle(color: Colors.grey),
                            // helperText: "Enter name to filter tickets",
                            // helperStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          onChanged: (text) {
                            isFieldEmpty = text.isEmpty;

                            onSearchQueryChanged(text);
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 3,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 30.0,
                      ),
                      onPressed: () => _selectDateRange(context),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.search,
                    //     color: Color.fromARGB(255, 0, 0, 0),
                    //     size: 24.0,
                    //   ),
                    //   onPressed: () {
                    //     print(this.chosen_entry_number);
                    //     print(this.chosen_start_date);
                    //     print(this.chosen_end_date);
                    //     print(this.isSelected);
                    //   },
                    // ),
                    // SizedBox(
                    //   width: 340,
                    // )
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the desired border color
                          borderRadius: BorderRadius.circular(
                              8.0), // Set the desired border radius
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              enableDateFilter = !enableDateFilter;
                              print("sssssssssssssssssssssssssssssssssssssss");
                              print(enableDateFilter);
                              filterTickets(searchQuery);
                            });
                          },
                          child: Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors
                                      .black, // Set the desired outline color
                                ),
                                child: Radio<bool>(
                                  activeColor: Colors
                                      .red, // Set the desired color for the radio button
                                  value: enableDateFilter,
                                  groupValue: true,
                                  onChanged: (value) {
                                    // setState(() {
                                    //   enableDateFilter = value!;
                                    // });
                                  },
                                ),
                              ),
                              Text(
                                'Date Filter  ',
                                style: TextStyle(
                                  color: enableDateFilter
                                      ? Colors.blue
                                      : Colors
                                          .black, // Set the desired color for the label
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Start Date: ${chosen_start_date.split(" ")[0]}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "End Date: ${chosen_end_date.split(" ")[0]}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: buildDataTable(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildDataTable() {
    late List<String> columns;
    if (Person == 'Students') {
      columns = ['Name', 'Time', 'Destination Address', 'Vehicle Number'];
    } else if (Person == 'Visitors') {
      columns = [
        'Visitor',
        'Mobile Number',
        'Car Number',
        'Purpose',
        'Authority Message',
        'Date/time',
        'Additonal Visitors'
      ];
    }

    if (Person == "Students") {
      return DataTable(
        border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
        headingRowColor:
            MaterialStateProperty.all(Color.fromARGB(255, 180, 180, 180)),
        columns: getColumns(columns),
        rows: getRows(ticketsFiltered),
        dataRowHeight: 100,
      );
    } else {
      // print("hello visitor tickets");
      return DataTable(
        border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
        headingRowColor:
            MaterialStateProperty.all(Color.fromARGB(255, 180, 180, 180)),
        columns: getColumns(columns),
        rows: getRows2(tickets_visitors),
        dataRowHeight: 100,
      );
    }
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

  List<DataRow> getRows(List<ResultObj> tickets) {
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
          }
          return null; // Use default value for other states and odd rows.
        }),
        // final columns = ['S.No.', 'Student Name', 'Time Generated', 'Entry/Exit', 'Authority Status'];
        cells: [
          DataCell(
            Row(
              children: [
                if (ticket.authority_status.toString() != 'NA')
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          AuthorityMessage(
                              ticket.authority_status.toString(), context);
                        },
                        icon: Icon(
                          Icons.message_outlined,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                      if (ticket.authority_status.contains("Approved"))
                        Icon(
                          Icons.check,
                          color: Colors.lightBlueAccent,
                          size: 24.0,
                        ),
                      if (ticket.authority_status.contains("Rejected"))
                        Icon(
                          Icons.cancel,
                          color: Colors.lightBlueAccent,
                          size: 24.0,
                        ),
                      if (ticket.authority_status.contains("Pending"))
                        Icon(
                          Icons.timer,
                          color: Colors.lightBlueAccent,
                          size: 24.0,
                        ),
                    ],
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          email: ticket.email.toString(),
                          isEditable: false,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    ticket.student_name.toString(),
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 42, 255),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // DataCell(
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //             builder: (context) =>
          //                 ProfilePage(email: ticket.email, isEditable: false)),
          //       );
          //     },
          //     child: Text(
          //       ticket.student_name.toString(),
          //       style: TextStyle(color: Colors.lightBlueAccent),
          //     ),
          //   ),
          // ),
          // Text(ticket.student_name.toString())),
          DataCell(Text(
            "    ${((ticket.date_time.split("T").last)
                        .split(".")[0]
                        .split(":")
                        .sublist(0, 2))
                    .join(":")}\n${ticket.date_time.split("T")[0]}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            ((ticket.destination_address)),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            ((ticket.vehicle_number)),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),

          // DataCell(Text(ticket.ticket_type.toString())),
          // DataCell(Text(ticket.authority_status.toString())),
        ],
      ));
    }
    return row_list;
  }

  List<DataRow> getRows2(List<ResultObj4> tickets) {
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
          }
          return null; // Use default value for other states and odd rows.
        }),
        // final columns = ['S.No.', 'Student Name', 'Time Generated', 'Entry/Exit', 'Authority Status'];
        cells: [
          DataCell(
            Row(
              children: [
                if (ticket.authority_status.toString() != 'NA')
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          AuthorityMessage(
                              ticket.authority_status.toString(), context);
                        },
                        icon: Icon(
                          Icons.message_outlined,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                      if (ticket.authority_status.contains("Approved"))
                        Icon(
                          Icons.check,
                          color: Colors.lightBlueAccent,
                          size: 24.0,
                        ),
                      if (ticket.authority_status.contains("Rejected"))
                        Icon(
                          Icons.cancel,
                          color: Colors.lightBlueAccent,
                          size: 24.0,
                        ),
                      if (ticket.authority_status.contains("Pending"))
                        Icon(
                          Icons.timer,
                          color: Colors.lightBlueAccent,
                          size: 24.0,
                        ),
                    ],
                  ),
                Text(
                  ticket.visitor_name,
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 42, 255),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          DataCell(Text(
            ticket.mobile_no,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),

          DataCell(Text(
            ticket.car_number,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            ticket.purpose,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            ticket.authority_message,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            "${((ticket.date_time_guard.split("T").last)
                        .split(".")[0]
                        .split(":")
                        .sublist(0, 1))
                    .join(":")}\n${ticket.date_time_guard.split("T")[0]}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    )),
          DataCell(Text(
            ticket.num_additional,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),

          // DataCell(Text(ticket.ticket_type.toString())),
          // DataCell(Text(ticket.authority_status.toString())),
        ],
      ));
    }
    return row_list;
  }
}
