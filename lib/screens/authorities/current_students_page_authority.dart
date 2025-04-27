import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_app/screens/authorities/authority_main.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/database/database_interface.dart';

class CurrentStudentsPageAuthority extends StatefulWidget {
  final String locationName;

  const CurrentStudentsPageAuthority({
    Key? key,
    required this.locationName,
  }) : super(key: key);

  @override
  State<CurrentStudentsPageAuthority> createState() =>
      _CurrentStudentsPageState();
}

class _CurrentStudentsPageState extends State<CurrentStudentsPageAuthority> {
  final Set<String> selectedEmails = {};
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _sortedStudents = [];
  bool _isLoading = false;
  String _sortBy = 'Name';
  String _currentFilter = 'current';
  DateTime? _selectedDate;
  bool _allSelected = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await databaseInterface.getStudentsInLocation(
        widget.locationName,
        filterType: _currentFilter,
        customDate: _selectedDate,
      );
      setState(() {
        _students = students;
        _sortedStudents = List.from(_students);
        _sortStudents();
      });
    } finally {
      setState(() => _isLoading = false);
    }
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

  void _toggleSelection(String email) {
    setState(() {
      if (selectedEmails.contains(email)) {
        selectedEmails.remove(email);
      } else {
        selectedEmails.add(email);
      }
    });
  }

  void _clearSelection() => setState(() {
        selectedEmails.clear();
        _allSelected = false;
      });

  void _selectAllToggle() {
    setState(() {
      if (_allSelected) {
        selectedEmails.clear();
      } else {
        selectedEmails.addAll(_students.map((s) => s['email'] as String));
      }
      _allSelected = !_allSelected;
    });
  }

  Future<void> _forceExitSelectedStudents() async {
    final selectedStudents = _students
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
      _clearSelection();
      _loadStudents(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to force exit students")),
      );
    }
  }

  Future<void> _showFilterDialog() async {
    final newFilter = await showModalBottomSheet<String>(
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
                'Filter Students',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Current Students', 'current'),
              _buildFilterOption("Today's Students", 'today'),
              _buildFilterOption('Last Week', 'last_week'),
              _buildFilterOption('Last Month', 'last_month'),
              _buildFilterOption('Custom Date', 'custom'),
              if (_currentFilter == 'custom' && _selectedDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Selected: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (newFilter == 'custom') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
          _currentFilter = 'custom';
        });
        _loadStudents();
      }
    } else if (newFilter != null) {
      setState(() {
        _currentFilter = newFilter;
        _selectedDate = null;
      });
      _loadStudents();
    }
  }

  ListTile _buildFilterOption(String title, String value) {
    return ListTile(
      leading: Icon(
        _currentFilter == value
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

  String _getFilterTitle() {
    switch (_currentFilter) {
      case 'current':
        return 'Current Students';
      case 'today':
        return "Today's Students";
      case 'last_week':
        return 'Students (Last Week)';
      case 'last_month':
        return 'Students (Last Month)';
      case 'custom':
        return _selectedDate != null
            ? 'Students on ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
            : 'Custom Date Students';
      default:
        return 'Students';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = selectedEmails.isNotEmpty;

    return GestureDetector(
      onTap: isSelectionMode ? _clearSelection : null,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            isSelectionMode
                ? "${selectedEmails.length} selected"
                : _getFilterTitle(),
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
                onPressed: _clearSelection,
              ),
          ],
        ),
        floatingActionButton: isSelectionMode
            ? FloatingActionButton.extended(
                backgroundColor: Colors.red,
                onPressed: _forceExitSelectedStudents,
                label: const Text("Force Exit"),
                icon: const Icon(Icons.logout),
              )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _sortedStudents.isEmpty
                ? Center(
                    child: Text(
                      'No students found',
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sortedStudents.length,
                    itemBuilder: (context, index) {
                      final student = _sortedStudents[index];
                      final isSelected =
                          selectedEmails.contains(student['email']);

                      return GestureDetector(
                        onTap: () => isSelectionMode
                            ? _toggleSelection(student['email']!)
                            : null,
                        onLongPress: () => _toggleSelection(student['email']!),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.white,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical:
                                    8, // Slightly more vertical padding for 3 lines
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
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name']!,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    student['email']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy • hh:mm a').format(
                                      DateTime.parse(student['entry_time']),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
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
                IconButton(
                  icon: const Icon(Icons.select_all,
                      color: Colors.white, size: 35),
                  onPressed: _selectAllToggle,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt,
                      color: Colors.white, size: 35),
                  onPressed: _showFilterDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 35),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AuthorityMain()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white, size: 35),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.grey[900],
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
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
                              _buildSortOption('Name'),
                              _buildSortOption('Entry Time'),
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

  ListTile _buildSortOption(String value) {
    return ListTile(
      leading: Icon(
        _sortBy == value ? Icons.radio_button_checked : Icons.radio_button_off,
        color: Colors.white,
      ),
      title: Text(
        value,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      ),
      onTap: () {
        setState(() => _sortBy = value);
        _sortStudents();
        Navigator.pop(context);
      },
    );
  }
}
