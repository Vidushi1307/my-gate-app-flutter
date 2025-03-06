import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen(
      {super.key,
      required this.location,
      required this.isApproved,
      required this.enterExit,
      required this.imagePath});
  final String location;
  final String isApproved;
  final String enterExit;
  final String imagePath;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

enum User { student, visitor, invitee }

class _TicketScreenState extends State<TicketScreen> {
  String searchQuery = '';

  List<ResultObj> tickets = [];
  List<ResultObj> ticketsFiltered = [];
  List<ResultObj4> tickets_visitors = [];
  List<ResultObj4> tickets_visitorsFiltered = [];
  List<InviteeRecord> invitee_records = [];
  List<InviteeRecord> invitee_recordsFiltered = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date =
      DateTime.now().subtract(const Duration(days: 1)).toString();
  String chosen_end_date = DateTime.now().toString();
  bool enableDateFilter = true;
  bool isFieldEmpty = true;
  User _person = User.student;
  Timer? _debounce;

  int selectedIndex = -1;

  void _togglePerson(User input) {
    if (input != _person) {
      setState(() {
        _person = input;
      });
      refreshInvitee();
    }
  }

  Widget header(String input) {
    if (input == 'enter') {
      return Text(
        "Enter Tickets",
        style: GoogleFonts.mPlusRounded1c(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );
    } else {
      return Text(
        "Exit Tickets",
        style: GoogleFonts.mPlusRounded1c(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );
    }
  }

  void filterTickets(String query) {
    if (_person == User.student) {
      filterStudentTickets(query);
    } else if (_person == User.visitor) {
      filterVisitorTickets(query);
    } else if (_person == User.invitee) {
      filterInviteeRecords(query);
    }
  }

  void filterStudentTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = tickets
            .where((ticket) =>
                DateTime.parse(ticket.date_time).toLocal().isBefore(
                    DateTime.parse(chosen_end_date)
                        .add(const Duration(days: 1))) &&
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
                    DateTime.parse(chosen_end_date)
                        .add(const Duration(days: 1))))
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

  void filterInviteeRecords(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        invitee_recordsFiltered = invitee_records
            .where((record) =>
                DateTime.parse(record.time).toLocal().isBefore(
                    DateTime.parse(chosen_end_date)
                        .add(const Duration(days: 1))) &&
                DateTime.parse(record.time)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)))
            .toList();
      } else {
        invitee_recordsFiltered = invitee_records
            .where((record) =>
                record.inviteeName
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(record.time)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)) &&
                DateTime.parse(record.time).toLocal().isBefore(
                    DateTime.parse(chosen_end_date)
                        .add(const Duration(days: 1))))
            .toList();
      }
    } else {
      if (query.isEmpty) {
        invitee_recordsFiltered = invitee_records;
      } else {
        invitee_recordsFiltered = invitee_records
            .where((record) =>
                record.inviteeName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }
  }

  void filterVisitorTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        tickets_visitorsFiltered = tickets_visitors
            .where((ticket) =>
                DateTime.parse(ticket.date_time_of_ticket_raised)
                    .toLocal()
                    .isBefore(DateTime.parse(chosen_end_date)
                        .add(const Duration(days: 1))) &&
                DateTime.parse(ticket.date_time_of_ticket_raised)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)))
            .toList();
      } else {
        tickets_visitorsFiltered = tickets_visitors
            .where((ticket) =>
                ticket.visitor_name
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.date_time_of_ticket_raised)
                    .toLocal()
                    .isAfter(DateTime.parse(chosen_start_date)) &&
                DateTime.parse(ticket.date_time_of_ticket_raised)
                    .toLocal()
                    .isBefore(DateTime.parse(chosen_end_date)
                        .add(const Duration(days: 1))))
            .toList();
        print(chosen_end_date);
      }
    } else {
      if (query.isEmpty) {
        tickets_visitorsFiltered = tickets_visitors;
      } else {
        tickets_visitorsFiltered = tickets_visitors
            .where((ticket) =>
                ticket.visitor_name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }
  }

  void resetFilter(String query) {
    chosen_start_date =
        DateTime.now().subtract(const Duration(days: 1)).toString();
    chosen_end_date = DateTime.now().toString();
    filterTickets(query);
  }

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query.toLowerCase();
        filterTickets(searchQuery);
      });
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );
    DateTimeRange? selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
    );
    if (selectedDateRange != null) {
      setState(() {
        chosen_start_date = selectedDateRange.start.toString();
        chosen_end_date = selectedDateRange.end.toString();
        filterTickets(searchQuery);
        ticketsFiltered = ticketsFiltered;
        tickets_visitorsFiltered = tickets_visitorsFiltered;
      });
      print("### $ticketsFiltered");
    }
  }

  Future<void> refreshInvitee() async {
    invitee_records = await get_tickets_invitee();
    filterInviteeRecords(searchQuery);
    setState(() {
      invitee_recordsFiltered = invitee_recordsFiltered;
    });
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
        widget.location, widget.isApproved, widget.enterExit);
  }

  Future<List<ResultObj4>> get_approved_tickets_for_visitors() async {
    print("%%33%%");
    return await databaseInterface.return_entry_visitor_approved_ticket(
        widget.location, widget.isApproved, widget.enterExit);
  }

  Future<List<InviteeRecord>> get_tickets_invitee() async {
    late final String statusType;
    if (widget.isApproved == "Approved") {
      statusType = "Accepted";
    } else {
      statusType = "Rejected";
    }
    return await databaseInterface.getInviteeRecords(
        widget.enterExit, statusType);
  }

  Future init() async {
    // tickets = await get_tickets_for_guard();
    late List<ResultObj> ticketsLocal;
    late List<ResultObj4> ticketsLocal2;
    late List<InviteeRecord> inviteeRecordsLocal;

    ticketsLocal = await get_tickets_for_guard();
    print("tickets_local :$ticketsLocal");

    ticketsLocal2 = await get_approved_tickets_for_visitors();
    print("tickets_local_2 :$ticketsLocal2");

    inviteeRecordsLocal = await get_tickets_invitee();

    setState(() {
      tickets = ticketsLocal;
      invitee_records = inviteeRecordsLocal;
      tickets_visitors = ticketsLocal2;
    });
    print("tickets_visitors set\n$tickets_visitors");
    filterTickets(searchQuery);
    setState(() {
      enableDateFilter = enableDateFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          header(widget.enterExit),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.07,
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.29,
                height: MediaQuery.of(context).size.height * 0.03,
                child: ElevatedButton(
                  onPressed: () {
                    _togglePerson(User.student);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_person == User.student)
                        ? hexToColor(guardColors[1])
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text(
                    "Student",
                    style: (_person == User.student)
                        ? GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                        : GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                  ),
                ),
              ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.07,
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.29,
                height: MediaQuery.of(context).size.height * 0.03,
                child: ElevatedButton(
                  onPressed: () {
                    _togglePerson(User.visitor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_person == User.visitor)
                        ? hexToColor(guardColors[1])
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text(
                    "Visitor",
                    style: (_person == User.visitor)
                        ? GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                        : GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.29,
                height: MediaQuery.of(context).size.height * 0.03,
                child: ElevatedButton(
                  onPressed: () {
                    _togglePerson(User.invitee);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_person == User.invitee)
                        ? hexToColor(guardColors[1])
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text(
                    "Invitee",
                    style: (_person == User.invitee)
                        ? GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                        : GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          // Text("${this._person.name}"),
          const SizedBox(
            height: 40,
          ),
          Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
            Container(
              // margin: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.73,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(30.0),
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
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.filter_alt,
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
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.filter_alt_off,
                    color: Colors.black87), // Filter icon
                onPressed: () {
                  setState(() {
                    enableDateFilter = !enableDateFilter;
                    resetFilter(searchQuery);
                    // filterTickets(searchQuery);
                  });
                },
              ),
            ),
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          if (_person == User.student)
            studentList(ticketsFiltered)
          else if (_person == User.visitor)
            visitorList(tickets_visitorsFiltered)
          else
            InviteeList(invitee_recordsFiltered),
        ]));
  }

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
        contentPadding: const EdgeInsets.fromLTRB(5.0, 0, 0, 14.0),
        hintText: 'Search by Name',
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.black),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.clear, color: Colors.black),
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

  Widget studentList(List<ResultObj> mytickets) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        // height:MediaQuery.of(context).size.height*0.67,
        child: ListView.builder(
          itemCount: mytickets.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[1]),
                          borderRadius: BorderRadius.circular(
                              15), // Adjust the radius as needed
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Text(
                                mytickets[index].student_name,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      5), // Add some space between the main text and the additional text
                              Text(
                                '(${mytickets[index].email.split('@').first})',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          children: <Widget>[
                            StudentDetails(mytickets[index]),
                          ],
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }

  Widget StudentDetails(ResultObj ticket) {
    // Parse the time string to DateTime object
    DateTime time = DateTime.parse(ticket.date_time).toLocal();
    print(ticket.date_time);
    print("datetime: $time");
    // Format the date and time
    String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Email :${ticket.email}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Mobile Number :${ticket.vehicle_number}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Time :$formattedTime",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Destination :${ticket.destination_address}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Vehicle Number :${ticket.vehicle_number}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
      ]),
    );
  }

  Widget visitorList(List<ResultObj4> mytickets) {
    print("widget visitor list");
    print(tickets_visitorsFiltered);
    return
        // mytickets.isEmpty
        //     ? Center(child: CircularProgressIndicator())
        //     :
        Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        // height:MediaQuery.of(context).size.height*0.67,
        child: ListView.builder(
          itemCount: mytickets.length,
          itemBuilder: (BuildContext context, int index) {
            final bool isExpanded = index == selectedIndex;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: hexToColor(guardColors[1]),
                        borderRadius: BorderRadius.circular(
                            15), // Adjust the radius as needed
                      ),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Text(
                              mytickets[index].visitor_name,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.06),
                            Text(DateFormat('hh:mm a - MMM dd, yyyy').format(
                                DateTime.parse(mytickets[index]
                                        .date_time_of_ticket_raised)
                                    .toLocal())),
                          ],
                        ),
                        children: <Widget>[
                          VisitorDetails(mytickets[index]),
                        ],
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                ]);
          },
        ),
      ),
    );
  }

  Widget VisitorDetails(ResultObj4 ticket) {
    DateTime time = DateTime.parse(ticket.date_time_of_ticket_raised).toLocal();

    // Format the date and time
    String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Duration :${ticket.duration_of_stay}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Mobile Number :${ticket.mobile_no}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Additonal Visitors :${ticket.num_additional}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Car Number: ${ticket.car_number}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text(
          "Time Ticket Raised: $formattedTime",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01)
      ]),
    );
  }

  Widget InviteeList(List<InviteeRecord> mytickets) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        // height:MediaQuery.of(context).size.height*0.67,
        child: ListView.builder(
          itemCount: mytickets.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: hexToColor(guardColors[1]),
                          borderRadius: BorderRadius.circular(
                              15), // Adjust the radius as needed
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Text(
                                mytickets[index].inviteeName,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05),
                              Text(
                                  "${mytickets[index].inviteeRelationship} of Student ${mytickets[index].studentName}")
                            ],
                          ),
                          children: <Widget>[
                            InviteeDetails(mytickets[index]),
                          ],
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }

  Widget InviteeDetails(InviteeRecord ticket) {
    // Parse the time string to DateTime object
    DateTime time = DateTime.parse(ticket.time).toLocal();

    // Format the date and time
    String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${ticket.inviteeRelationship} of ",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w300,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Text(
            "Student ${ticket.studentName} (${ticket.studentEntryNo})",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Time: $formattedTime",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Vehicle Number: ${ticket.vehicleNumber}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          AcceptRejectInvitee(ticket.recordId, ticket.status)
        ],
      ),
    );
  }

  Widget AcceptRejectInvitee(int recordId, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: status == "Rejected",
          child: ElevatedButton(
            onPressed: () async {
              await databaseInterface.updateInviteeRecordStatus(
                  recordId, "Accepted");
              invitee_records = await get_tickets_invitee();
              filterInviteeRecords(searchQuery);
              setState(() {
                invitee_recordsFiltered = invitee_recordsFiltered;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
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
          visible: status == "Accepted",
          child: ElevatedButton(
            onPressed: () async {
              // selectedTickets_action.add(tickets[index]);
              // await reject_action_tickets_authorities();
              await databaseInterface.updateInviteeRecordStatus(
                  recordId, "Rejected");
              invitee_records = await get_tickets_invitee();
              filterInviteeRecords(searchQuery);
              setState(() {
                invitee_recordsFiltered = invitee_recordsFiltered;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
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
    );
  }
}
