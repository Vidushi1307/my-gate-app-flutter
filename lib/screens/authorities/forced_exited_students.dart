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

  bool _sortByName = false; // Tracks current sort mode

  String _formatToIST(String? isoTime) {
    if (isoTime == null) return 'Still inside';
    
    try {
      final dateTime = DateTime.parse(isoTime).toLocal();
      
      // Manual formatting without intl package
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final amPm = dateTime.hour < 12 ? 'AM' : 'PM';
      
      return '$day-$month-$year $hour:$minute $amPm';
    } catch (e) {
      return isoTime; // Return original if parsing fails
    }
  }


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

  void _sortStudents() {
    setState(() {
      _sortByName = !_sortByName;
    });
  }

  List<Map<String, dynamic>> _getSortedStudents() {
    final List<Map<String, dynamic>> studentsCopy = List<Map<String, dynamic>>.from(students);
    if (_sortByName) {
      studentsCopy.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } else {
      studentsCopy.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    }
    return studentsCopy;
}


  @override
  Widget build(BuildContext context) {
    final sortedStudents = _getSortedStudents();

    return Scaffold(
      backgroundColor: Colors.white, // White background for the page
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Force Exited Students",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: sortedStudents.isEmpty
          ? const Center(
              child: Text(
                "No forced exits found",
                style: TextStyle(color: Colors.black),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              //itemCount: students.length,
              itemCount: sortedStudents.length,
              itemBuilder: (context, index) {
                var student = sortedStudents[index];
                return Card(
                  color: const Color.fromARGB(255, 5, 48, 91), // Black card
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
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 4),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate appropriate font size based on available width
                            final textPainter = TextPainter(
                              text: TextSpan(
                                text: student['email'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14, // Start with this size
                                ),
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            double fontSize = 14;
                            if (textPainter.didExceedMaxLines) {
                              // Reduce font size if text is too long
                              fontSize = 12;
                            }

                            return Text(
                              student['email'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: fontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          },
                        ),
                      ],
                    ),
                      subtitle: Text(
                        "Forced Exits: ${student['count']}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.bold
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
                            "Entry: ${_formatToIST(student["sessions"][i]["entry_time"])}\n"
                            "Exit: ${_formatToIST(student["sessions"][i]["exit_time"])}",
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
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 5, 48, 91),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text('Sort by Name'),
                          onTap: () {
                            setState(() {
                              _sortByName = true;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                    leading: const Icon(Icons.format_list_numbered),
                    title: const Text('Sort by Force Exits'),
                    onTap: () {
                      setState(() {
                        _sortByName = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.sort, color: Colors.white),
      ),
    );
  }
}
