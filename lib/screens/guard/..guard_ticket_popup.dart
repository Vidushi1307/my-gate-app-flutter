import 'package:flutter/material.dart';

Widget GuardTicketPopup(){
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    elevation: 16,
    child: Container(
      child: ListView(
        shrinkWrap: true,
        children: const <Widget>[
          SizedBox(height: 20),
          Center(child: Text('Ticket Details')),
          SizedBox(height: 20),
          Text("Location: Main Gate"),
          Text("Student Name: xyz pqr"),
          Text("Date: 17/3/22"),
          Text("Time: 23:36"),
          Text("Entry/Exit: Entry"),
          Text("Pre Approval: NA"),
          Text("Authority: Dr. Verma"),
          Text("Status: Pending"),
          Text("Guard: Mr. qwe"),
        ],
      ),
    ),
  );
}
