// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, avoid_print, must_be_immutable, prefer_collection_literals, prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/utils/authority_message.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/utils/scrollable_widget.dart';

// Rename this class to PendingGuardTicketTable and change in all files where it being called

class SelectablePage extends StatefulWidget {
  const SelectablePage(
      {super.key, required this.location, required this.enter_exit});
  final String location;
  final String enter_exit;

  @override
  _SelectablePageState createState() => _SelectablePageState();
}

enum SingingCharacter { Students, Visitors }

class _SelectablePageState extends State<SelectablePage> {
  final SingingCharacter _character = SingingCharacter.Students;
  String ticket_accepted_message = '';
  String ticket_rejected_message = '';
  String Person = "Visitors";
  String searchQuery = '';
  bool enableDateFilter = false;
  bool isFieldEmpty = true;

  List<ResultObj> tickets = [];
  List<ResultObj4> tickets_visitors = [];
  List<ResultObj4> filtered_tickets_visitors = [];

  List<ResultObj> selectedTickets = [];
  List<ResultObj4> selectedTickets_visitors = [];

  List<ResultObj> selectedTickets_action = [];
  List<ResultObj4> selectedTickets_visitors_action = [];

  var entryNumToEmailMap = new Map();
  var emailToEntryNumMap = new Map();

  List<String> list_of_persons = [];
  String chosen_entry_number = "None";
  String chosen_mobile_number = "None";
  String chosen_name = "None";

  String chosen_start_date = "None";
  String chosen_end_date = "None";
  bool date_filter_applied = false;
  bool ticket_type_filter_applied = false;

  List<bool> isSelected = [true, true];

  Future<void> accept_selected_tickets() async {
    databaseInterface db = new databaseInterface();
    int status_code = 0;
    if (Person == 'Students') {
      status_code = await db.accept_selected_tickets(selectedTickets);
    } else if (Person == 'Visitors') {
      status_code =
          await db.accept_selected_tickets_visitors(selectedTickets_visitors);
    }
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Selected tickets accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar =
          get_snack_bar("Failed to accept the tickets", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_selected_tickets() async {
    databaseInterface db = new databaseInterface();
    int status_code = 0;
    if (Person == 'Students') {
      status_code = await db.reject_selected_tickets(selectedTickets);
    } else if (Person == 'Visitors') {
      status_code =
          await db.reject_selected_tickets_visitors(selectedTickets_visitors);
    }
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Selected tickets rejected", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar =
          get_snack_bar("Failed to reject the tickets\n", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> accept_action_tickets() async {
    databaseInterface db = new databaseInterface();
    int status_code = 0;
    if (Person == 'Students') {
      status_code = await db.accept_selected_tickets(selectedTickets_action);
    } else if (Person == 'Visitors') {
      status_code = await db
          .accept_selected_tickets_visitors(selectedTickets_visitors_action);
    }
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket Accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar =
          get_snack_bar("Failed to accept that ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_action_tickets() async {
    databaseInterface db = new databaseInterface();
    int status_code = 0;
    if (Person == 'Students') {
      status_code = await db.reject_selected_tickets(selectedTickets_action);
    } else if (Person == 'Visitors') {
      status_code = await db
          .reject_selected_tickets_visitors(selectedTickets_visitors_action);
    }
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket Rejected", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar =
          get_snack_bar("Failed to reject the ticket\n", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        filtered_tickets_visitors = tickets_visitors
            .where((ticket) => DateTime.parse(ticket.date_time_of_ticket_raised)
                .toLocal()
                .isBefore(
                    DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
      } else {
        filtered_tickets_visitors = tickets_visitors
            .where((ticket) =>
                ticket.visitor_name
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.date_time_of_ticket_raised)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)) &&
                DateTime.parse(ticket.date_time_of_ticket_raised)
                    .toLocal()
                    .isBefore(
                        DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
        print(chosen_end_date);
      }
    } else {
      if (query.isEmpty) {
        filtered_tickets_visitors = tickets_visitors;
      } else {
        filtered_tickets_visitors = tickets_visitors
            .where((ticket) =>
                ticket.visitor_name.toLowerCase().contains(query.toLowerCase()))
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

  Future<List<ResultObj>> get_pending_tickets_for_guard() async {
    return await databaseInterface.get_pending_tickets_for_guard(
        widget.location, widget.enter_exit);
  }

  Future<List<ResultObj4>> get_pending_tickets_for_visitors() async {
    return await databaseInterface
        .get_pending_tickets_for_visitors(widget.enter_exit);
  }

  List<String> segregrateTicketEntries(List<String> allTickets) {
    List<String> ans = [];

    entryNumToEmailMap = new Map();
    emailToEntryNumMap = new Map();

    for (var element in allTickets) {
      var list = element.split("\n");
      var entry_number = list[0].split(",")[0];
      ans.add(list[0]);
      if (Person == "Students") {
        var email = list[1];
        entryNumToEmailMap[entry_number] = email;
        emailToEntryNumMap[email] = entry_number;
      }
    }

    return ans;
  }

  Future init() async {
    // ignore: unused_local_variable
    var tickets_local;

    if (Person == 'Students') {
      tickets_local = await get_pending_tickets_for_guard();
    } else {
      tickets_local = await get_pending_tickets_for_visitors();
    }

    var list_of_persons_local;

    if (Person == 'Students') {
      list_of_persons_local =
          await databaseInterface.get_list_of_entry_numbers("guards");
    } else {
      list_of_persons_local = await databaseInterface.get_list_of_visitors();
    }

    setState(() {
      if (Person == 'Students') {
        tickets = tickets_local;
        selectedTickets = [];
        selectedTickets_action = [];
      } else {
        tickets_visitors = tickets_local;
        selectedTickets_visitors = [];
        selectedTickets_visitors_action = [];
      }

      list_of_persons = segregrateTicketEntries(list_of_persons_local);
    });
    filterTickets(searchQuery);
  }

  void apply_filters() {
    if (Person == "Students") {
      List<ResultObj> tickets_local = tickets;
      if (ticket_type_filter_applied) {
        print("Ticket Type Filtered Applied");
        if ((isSelected[0] && isSelected[1]) == false) {
          print("Not Both true");
          if (isSelected[0]) {
            print("First True");
            List<ResultObj> tickets_local_1 = [];
            for (int i = 0; i < tickets_local.length; i++) {
              print("Ticket Type: ${tickets[i].ticket_type}");
              if (tickets[i].ticket_type == 'enter') {
                tickets_local_1.add(tickets[i]);
              }
            }
            tickets_local = tickets_local_1;
          } else {
            List<ResultObj> tickets_local_1 = [];
            for (int i = 0; i < tickets_local.length; i++) {
              if (tickets[i].ticket_type == 'exit') {
                tickets_local_1.add(tickets[i]);
              }
            }
            tickets_local = tickets_local_1;
          }
        }
      }
      if (date_filter_applied) {
        List<ResultObj> tickets_local_1 = [];
        for (int i = 0; i < tickets_local.length; i++) {
          var ticket_date = tickets_local[i].date_time.split("T")[0];
          print("date time of ticket ${tickets_local[i].date_time}");
          var start_match = ticket_date.compareTo(chosen_start_date);
          var end_match = ticket_date.compareTo(chosen_end_date);
          if (start_match >= 0 && end_match <= 0) {
            tickets_local_1.add(tickets[i]);
          }
        }
        tickets_local = tickets_local_1;
      }
      if (chosen_entry_number != "None") {
        // TODO Uncomment this code after committing the map
        List<ResultObj> tickets_local_1 = [];
        for (int i = 0; i < tickets_local.length; i++) {
          if (emailToEntryNumMap[tickets[i].email] == chosen_entry_number) {
            tickets_local_1.add(tickets[i]);
          }
        }
        tickets_local = tickets_local_1;
      }
      setState(() {
        tickets = tickets_local;
        selectedTickets = [];
      });
    } else if (Person == 'Visitors') {
      List<ResultObj4> tickets_local = tickets_visitors;
      if (date_filter_applied) {
        List<ResultObj4> tickets_local_1 = [];
        for (int i = 0; i < tickets_local.length; i++) {
          var ticket_date =
              tickets_local[i].date_time_of_ticket_raised.split("T")[0];
          var start_match = ticket_date.compareTo(chosen_start_date);
          var end_match = ticket_date.compareTo(chosen_end_date);
          if (start_match >= 0 && end_match <= 0) {
            tickets_local_1.add(tickets_visitors[i]);
          }
        }
        tickets_local = tickets_local_1;
      }
      if (chosen_mobile_number != "None") {
        List<ResultObj4> tickets_local_1 = [];
        for (int i = 0; i < tickets_local.length; i++) {
          if (tickets_visitors[i].mobile_no == chosen_mobile_number &&
              tickets_visitors[i].visitor_name == chosen_name) {
            tickets_local_1.add(tickets_visitors[i]);
          }
        }
        tickets_local = tickets_local_1;
      }

      setState(() {
        tickets_visitors = tickets_local;
        selectedTickets_visitors = [];
      });
    }
  }

  void filterTicketsByEntryNumber(String entry_number) {
    List<ResultObj> new_tickets = [];
    entry_number = entry_number.split(",")[0];
    var email = entryNumToEmailMap[entry_number];

    // print("Entry number of student is: " + entry_number);
    // print("Email of student is: " + email);
    for (var element in tickets) {
      if (element.email == email) {
        new_tickets.add(element);
      }
    }

    setState(() {
      tickets = new_tickets;
      selectedTickets = [];
    });
  }

  @override
  Widget build(BuildContext context) => Container(
        child: Scaffold(
          backgroundColor: Colors.brown[50],
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ScrollableWidget(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  if (widget.enter_exit == "enter")

                    // Padding(
                    //   padding: EdgeInsets.only(top:25,left:100,right:100),
                    //   child: ElevatedButton.icon(
                    //    icon: Icon(
                    //      Icons.supervised_user_circle,
                    //      color: Colors.grey[200],
                    //      size: 18.0,
                    //    ),
                    //    onPressed: () async {
                    //      Navigator.push(
                    //        context,
                    //        MaterialPageRoute(
                    //          builder: (context) => selectVisitor(),
                    //        ),
                    //      );
                    //    },
                    //    label: Text(
                    //      "Add Visitor Ticket",
                    //      style: TextStyle(
                    //        color: Colors.grey[200],
                    //        fontWeight: FontWeight.bold,
                    //      ),
                    //    ),
                    //    style: ButtonStyle(
                    //      backgroundColor: MaterialStateProperty.all<Color>(
                    //        Colors.brown[400]!,
                    //      ),
                    //      shape: MaterialStateProperty.all<
                    //          RoundedRectangleBorder>(
                    //        RoundedRectangleBorder(
                    //          borderRadius: BorderRadius.circular(10),
                    //        ),
                    //      ),
                    //      elevation: MaterialStateProperty.all<double>(4),
                    //      padding:
                    //          MaterialStateProperty.all<EdgeInsetsGeometry>(
                    //        EdgeInsets.symmetric(
                    //          horizontal: 20,
                    //          vertical: 10,
                    //        ),
                    //      ),
                    //    ),
                    //                               ),
                    // ),

                    SizedBox(
                      height: 10,
                    ),

                  SizedBox(
                    height: 20,
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
                            style:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                                color: Colors
                                    .grey), // Set the desired border color
                            borderRadius: BorderRadius.circular(
                                8.0), // Set the desired border radius
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                enableDateFilter = !enableDateFilter;
                                print(
                                    "sssssssssssssssssssssssssssssssssssssss");
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
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () async {
                            await accept_selected_tickets();
                          },
                          tooltip: "accept the selected ticket",
                          icon: Icon(
                            Icons.check_circle_outlined,
                            color: Colors.green,
                            size: 50.0,
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 255, 254, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double>(10),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () async {
                            await reject_selected_tickets();
                          },
                          tooltip: "reject the selected tickets",
                          iconSize: 50,
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 50.0,
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 255, 255, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double>(10),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () async {
                            init();
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: Color.fromARGB(255, 8, 8, 8),
                            size: 50.0,
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 255, 255, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double>(10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center(
                  //   child: Container(
                  //     padding: EdgeInsets.all(1),
                  //     child: Text(
                  //       // "Ticket Table",
                  //       "",
                  //       style: GoogleFonts.roboto(
                  //           fontSize: 20, fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  // buildDataTable()
                  // Text("No entries available in the ticket table"),
                  // Testing()
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      ScrollableWidget(child: buildDataTable()),
                    ],
                  ),
                  // Expanded(child: ScrollableWidget(child: buildDataTable())),
                  // buildSubmit(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildDataTable() {
    var columns;
    if (Person == 'Students') {
      columns = [
        'Name',
        'Action',
        'Time',
      ];
    } else if (Person == 'Visitors') {
      columns = [
        'Visitor',
        'Car Number',
        'Purpose',
        'Action',
      ];
    }

    if (Person == 'Students') {
      return DataTable(
        onSelectAll: (isSelectedAll) {
          setState(() => selectedTickets = isSelectedAll! ? tickets : []);
          // Utils.showSnackBar(context, 'All Selected: $isSelectedAll');
        },
        border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
        headingRowColor:
            MaterialStateProperty.all(Color.fromARGB(255, 180, 180, 180)),
        columns: getColumns(columns),
        rows: getRows(tickets),
        dataRowHeight: 100,
      );
    } else {
      return DataTable(
        onSelectAll: (isSelectedAll) {
          setState(() => selectedTickets_visitors =
              isSelectedAll! ? filtered_tickets_visitors : []);
          // Utils.showSnackBar(context, 'All Selected: $isSelectedAll');
        },
        border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
        headingRowColor:
            MaterialStateProperty.all(Color.fromARGB(255, 180, 180, 180)),
        columns: getColumns(columns),
        rows: getRows2(filtered_tickets_visitors),
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
        selected: selectedTickets.contains(ticket),
        onSelectChanged: (isSelected) => setState(() {
          final isAdding = isSelected != null && isSelected;
          isAdding
              ? selectedTickets.add(ticket)
              : selectedTickets.remove(ticket);
          print(selectedTickets);
        }),
        cells: [
          // DataCell(Text((index + 1).toString())),
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
                        color: Color.fromARGB(255, 14, 105, 251),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Column(
              children: [
                IconButton(
                  // Action Button Tick
                  onPressed: () async {
                    selectedTickets_action.add(ticket);
                    await accept_action_tickets();
                  },
                  icon: Icon(
                    Icons.check_circle_outlined,
                    color: Colors.green,
                    size: 24.0,
                  ),
                ),
                IconButton(
                  // Action Button Cross
                  onPressed: () async {
                    selectedTickets_action.add(ticket);
                    await reject_action_tickets();
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Text(
              "    ${((ticket.date_time.split("T").last).split(".")[0].split(":").sublist(0, 2)).join(":")}\n${ticket.date_time.split("T")[0]}",
              style: TextStyle(color: Colors.black),
            ),
          ),

          // DataCell(Text(ticket.ticket_type.toString())),
          // DataCell(Text(ticket.authority_status.toString())),
        ],
      ));
    }
    // print("row_list");
    // print(row_list);
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
          },
        ),
        selected: selectedTickets_visitors.contains(ticket),
        onSelectChanged: (isSelected) => setState(() {
          final isAdding = isSelected != null && isSelected;

          isAdding
              ? selectedTickets_visitors.add(ticket)
              : selectedTickets_visitors.remove(ticket);
        }),
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
                              "${ticket.authority_name}, ${ticket.authority_designation}\n${ticket.authority_status}\n${ticket.authority_message}\n\n",
                              context);
                        },
                        icon: Icon(
                          Icons.message_outlined,
                          color: Colors.black, // Set the icon color to black
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
                  "${ticket.visitor_name}\n${ticket.mobile_no}",
                  style:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
              ],
            ),
          ),
          DataCell(
            Text(
              ticket.car_number,
              style: TextStyle(color: Colors.black), // Set text color to black
            ),
          ),
          DataCell(
            Text(
              ticket.purpose,
              style: TextStyle(color: Colors.black), // Set text color to black
            ),
          ),
          DataCell(
            Column(
              children: [
                IconButton(
                  onPressed: () async {
                    selectedTickets_visitors_action.add(ticket);
                    await accept_action_tickets();
                  },
                  icon: Icon(
                    Icons.check_circle_outlined,
                    color: Colors.green,
                    size: 24.0,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    selectedTickets_visitors_action.add(ticket);
                    await reject_action_tickets();
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ));
    }
    return row_list;
  }
}
