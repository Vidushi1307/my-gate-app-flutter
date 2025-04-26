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

  String _sortBy = 'Name';
  List<Map<String, dynamic>> _sortedStudents = [];

  @override
  void initState() {
    super.initState();
    _sortedStudents = List.from(widget.students); // Make a local copy to sort
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
    setState(() => selectedEmails.clear());
  }

  void selectAll() {
    setState(() {
      selectedEmails.addAll(widget.students.map((s) => s['email'] as String));
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

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) clearSelection();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
            if (!isSelectionMode)
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: selectAll,
              ),
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: clearSelection,
              ),
            if (!isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DropdownButton<String>(
                  dropdownColor: Colors.black,
                  value: _sortBy,
                  icon: const Icon(Icons.sort, color: Colors.white),
                  underline: Container(),
                  style: const TextStyle(color: Colors.white),
                  selectedItemBuilder: (BuildContext context) {
                    return ['  Name', 'Entry Time'].map((e) {
                      return Center(
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: ['Name', 'Entry Time']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _sortBy = value;
                      _sortStudents();
                    }
                  },
                ),
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
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : null,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
