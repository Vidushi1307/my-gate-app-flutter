import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
class StudentCountText extends StatefulWidget {
  final String locationName;

  const StudentCountText({required this.locationName});

  @override
  State<StudentCountText> createState() => _StudentCountTextState();
}

class _StudentCountTextState extends State<StudentCountText> {
  late Future<int> _studentCountFuture;

  @override
  void initState() {
    super.initState();
    // Fetch count AFTER widget is built (non-blocking)
    _studentCountFuture = _fetchStudentCount();
  }

  Future<int> _fetchStudentCount() async {
    final students = await databaseInterface.getStudentsInLocation(widget.locationName);
    return students.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _studentCountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "",
            style: TextStyle(color: Colors.black54, fontSize: 8),
          );
        }
        return Text(
          "${snapshot.data ?? 0} ${snapshot.data == 1 ? 'student' : 'students'} in Lab",
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          height: 2.5,
          ),
        );
      },
    );
  }
}