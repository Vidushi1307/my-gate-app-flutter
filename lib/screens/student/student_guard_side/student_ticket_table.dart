// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:intl/intl.dart';

class StudentTicketTable extends StatefulWidget {
  StudentTicketTable({
    super.key,
    required this.location,
    required this.tickets,
    required this.pre_approval_required,
  });
  final String location;
  List<ResultObj> tickets;
  final bool pre_approval_required;

  @override
  _StudentTicketTableState createState() => _StudentTicketTableState();
}

class _StudentTicketTableState extends State<StudentTicketTable> {
  // List<TicketResultObj> tickets = [];

  @override
  void initState() {
    super.initState();
    // init();
  }

  Color getColorForType(String status) {
    switch (status) {
      // case "enter":
      //   return Color(0xff3E3E3E); // Change to your desired color
      case "enter":
        return Color(0xff3E5D5D); // Change to your desired color
      case "exit":
        return Color(0xff3E1313); // Change to your desired color
      default:
        return Colors.grey; // Default color
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white, // added now
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(
                    itemCount: widget.tickets.length,
                    itemBuilder: (BuildContext context, int index) {
                      // final bool isExpanded = index == selectedIndex;
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: getColorForType(
                                      widget.tickets[index].ticket_type),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ExpansionTile(
                                  // tilePadding: EdgeInsets.zero, // Remove padding
                                  // backgroundColor: Colors.transparent, // Optional: Set background color to transparent if needed
                                  // collapsedBackgroundColor: Colors.transparent,
                                  title: Row(
                                    children: [
                                      Text(
                                        (widget.tickets[index].ticket_type ==
                                                'enter')
                                            ? "Enter"
                                            : (widget.tickets[index]
                                                        .ticket_type ==
                                                    'exit')
                                                ? 'Exit'
                                                : widget
                                                    .tickets[index].ticket_type,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(DateFormat('hh:mm a - MMM dd, yyyy')
                                          .format(DateTime.parse(widget
                                                  .tickets[index].date_time)
                                              .toLocal())),
                                    ],
                                  ),
                                  children: <Widget>[
                                    Details(widget.tickets[index]),
                                  ],
                                )),
                            SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget Details(ResultObj ticket) {
    // Parse the time string to DateTime object
    DateTime time = DateTime.parse(ticket.date_time).toLocal();
    print(ticket.date_time);
    print("datetime: $time");
    // Format the date and time
    String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Destination :${ticket.destination_address}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              fontSize: 15,
            )),
        Text("Vehicle Number :${ticket.vehicle_number}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              fontSize: 15,
            )),
        Text("IsApproved :${ticket.is_approved}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              fontSize: 15,
            )),
        SizedBox(
          height: 10,
        )
      ]),
    );
  }
}
