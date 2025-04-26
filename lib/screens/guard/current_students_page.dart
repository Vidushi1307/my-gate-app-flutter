import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/guard/enter_exit.dart';

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

  String _sortBy = 'Name';
  List<Map<String, dynamic>> _sortedStudents = [];
  bool allSelected = false;

  @override
  void initState() {
    super.initState();
    _sortedStudents = List.from(widget.students);
    _sortStudents();
  }

  void _sortStudents() {
    setState(() {
      if (_sortBy == 'Name') {
        _sortedStudents.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (_sortBy == 'Entry Time') {
        _sortedStudents.sort((a, b) {
          final at = DateTime.tryParse(a['entry_time'] ?? '') ?? DateTime.now();
          final bt = DateTime.tryParse(b['entry_time'] ?? '') ?? DateTime.now();
          return at.compareTo(bt);
        });
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedEmails.clear();
      allSelected = false;
    });
  }

  void selectAllToggle() {
    setState(() {
      if (allSelected) {
        selectedEmails.clear();
      } else {
        selectedEmails.addAll(widget.students.map((s) => s['email'] as String));
      }
      allSelected = !allSelected;
    });
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to force exit students")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = selectedEmails.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) clearSelection();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
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
          actions: [
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: clearSelection,
              ),
          ],
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
                itemCount: _sortedStudents.length,
                itemBuilder: (context, index) {
                  final student = _sortedStudents[index];
                  final isSelected = selectedEmails.contains(student['email']);

                  return GestureDetector(
                    onTap: () {
                      if (isSelectionMode) {
                        toggleSelection(student['email']!);
                      }
                    },
                    onLongPress: () {
                      if (!isSelectionMode) {
                        toggleSelection(student['email']!);
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.blue.shade100 : Colors.white,
                          // gradient: isSelected
                          //     ? null
                          //     : const RadialGradient(
                          //         center: Alignment.center,
                          //         radius: 5.0,
                          //         colors: [
                          //           Color.fromARGB(255, 53, 147, 254),
                          //           Color(0xFFE6F4FF),
                          //         ],
                          //         stops: [0.0, 1.0],
                          //       ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
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
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            student['email']!,
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.black54,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 65, 65, 67),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Select All Button
                IconButton(
                  icon: const Icon(Icons.select_all, color: Colors.white, size: 35),
                  onPressed: selectAllToggle,
                ),

                // Home Button
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 35),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EntryExit(guard_location: "CS Block")),
                    );
                  },
                ),

                // Sort Button
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white, size: 35),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.grey[900],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sort By',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListTile(
                                leading: Icon(
                                  _sortBy == 'Name' ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Name',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                                ),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Name';
                                    _sortStudents();
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  _sortBy == 'Entry Time' ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Entry Time',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                                ),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Entry Time';
                                    _sortStudents();
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
