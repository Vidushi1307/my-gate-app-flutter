// // ignore_for_file: non_constant_identifier_names
//
// import 'package:flutter/material.dart';
// import 'package:my_gate_app/database/database_interface.dart';
// import 'package:my_gate_app/database/database_objects.dart';
// import 'package:my_gate_app/get_email.dart';
// import 'package:my_gate_app/screens/authorities/relatives/relatives_rejected_ticket_table.dart';
//
// // The code for this file is not updated according to the authority, it is using the guard version
//
// class StreamRelativesTicketTable extends StatefulWidget {
//   const StreamRelativesTicketTable({
//     super.key,
//     required this.is_approved,
//     required this.image_path,
//   });
//   final String is_approved;
//   final String image_path;
//
//   @override
//   State<StreamRelativesTicketTable> createState() =>
//       _StreamRelativesTicketTableState();
// }
//
// class _StreamRelativesTicketTableState
//     extends State<StreamRelativesTicketTable> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: databaseInterface.get_relative_tickets_for_authorities_stream(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return const Center(child: CircularProgressIndicator());
//           default:
//             if (snapshot.hasError) {
//               return const Text("Error",
//                   style: TextStyle(fontSize: 24, color: Colors.red));
//             } else {
//               // String in_or_out = snapshot.data.toString();
//               return RelativesTicketTable(
//                   is_approved: widget.is_approved,
//                   image_path: widget.image_path
//               );
//             }
//         }
//       },
//     );
//   }
// }
