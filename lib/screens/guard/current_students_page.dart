// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';

// class CurrentStudentsPage extends StatelessWidget {
//   final String locationName;
//   final List<Map<String, dynamic>> students;

//   const CurrentStudentsPage({
//     Key? key,
//     required this.locationName,
//     required this.students,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: hexToColor(guardColors[0]),
//         title: Text(
//           'Students in $locationName',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: students.isEmpty
//           ? Center(
//               child: Text(
//                 'No students currently in $locationName',
//                 style: GoogleFonts.poppins(fontSize: 18),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: students.length,
//               itemBuilder: (context, index) {
//                 final student = students[index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     leading: CircleAvatar(
//                       backgroundColor: hexToColor(guardColors[2]),
//                       child: Text(
//                         student['name']!.substring(0, 1),
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     title: Text(
//                       student['name']!,
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Text(
//                       student['email']!,
//                       style: GoogleFonts.poppins(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/database/database_interface.dart';

class CurrentStudentsPage extends StatefulWidget {
  final String locationName;
  final List<Map<String, dynamic>> students;

  const CurrentStudentsPage({
    Key? key,
    required this.locationName,
    required this.students,
  }) : super(key: key);

  @override
  State<CurrentStudentsPage> createState() => _CurrentStudentsPageState();
}

class _CurrentStudentsPageState extends State<CurrentStudentsPage> {
  final Set<String> selectedEmails = {};

  void toggleSelection(String email) {
    setState(() {
      if (selectedEmails.contains(email)) {
        selectedEmails.remove(email);
      } else {
        selectedEmails.add(email);
      }
    });
  }

  void clearSelection() {
    setState(() => selectedEmails.clear());
  }

  void forceExitSelectedStudents() async {
    final selectedStudents = widget.students
        .where((student) => selectedEmails.contains(student['email']))
        .toList();

    final success = await databaseInterface.forceExitStudents(
      widget.locationName,
      selectedStudents,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Force exited selected students")),
      );
      clearSelection();
      Navigator.pop(context); // You can refresh this page instead if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to force exit students")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = selectedEmails.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: hexToColor(guardColors[0]),
        title: Text(
          isSelectionMode
              ? "${selectedEmails.length} selected"
              : 'Students in ${widget.locationName}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: clearSelection,
                )
              ]
            : null,
      ),
      floatingActionButton: isSelectionMode
          ? FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: forceExitSelectedStudents,
              label: const Text("Force Exit"),
              icon: const Icon(Icons.logout),
            )
          : null,
      body: widget.students.isEmpty
          ? Center(
              child: Text(
                'No students currently in ${widget.locationName}',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                final isSelected = selectedEmails.contains(student['email']);

                return GestureDetector(
                  onLongPress: () => toggleSelection(student['email']!),
                  onTap: () {
                    if (isSelectionMode) {
                      toggleSelection(student['email']!);
                    }
                  },
                  child: Card(
                    color: isSelected ? Colors.blue.shade100 : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: hexToColor(guardColors[2]),
                        child: Text(
                          student['name']!.substring(0, 1),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        student['name']!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        student['email']!,
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
