import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';

class ForcedExitedStudentsPage extends StatefulWidget {
  const ForcedExitedStudentsPage({super.key});

  @override
  State<ForcedExitedStudentsPage> createState() =>
      _ForcedExitedStudentsPageState();
}

class _ForcedExitedStudentsPageState extends State<ForcedExitedStudentsPage> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var result = await databaseInterface.getForcedExitedStudents();
    setState(() {
      students = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for the page
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Forced Exited Students",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: students.isEmpty
          ? const Center(
              child: Text(
                "No forced exits found",
                style: TextStyle(color: Colors.black),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: students.length,
              itemBuilder: (context, index) {
                var student = students[index];
                return Card(
                  color: Colors.black, // Black card
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.white.withOpacity(0.2),
                    ),
                    child: ExpansionTile(
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      title: Text(
                        "${student['name']} (${student['email']})",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Forced Exits: ${student['count']}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      children: List.generate(
                        student["sessions"].length,
                        (i) => ListTile(
                          title: Text(
                            "Location: ${student["sessions"][i]["location"]}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            "Entry: ${student["sessions"][i]["entry_time"]}\nExit: ${student["sessions"][i]["exit_time"] ?? 'Still inside'}",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[300],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
