import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart'; // Adjusted import path
import 'package:my_gate_app/image_paths.dart' as image_paths;
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/guard/current_students_page.dart'; // Adjusted import path

class LocationDetailPage extends StatelessWidget {
  final String locationName;
  final String? imagePath;

  const LocationDetailPage({
    Key? key,
    required this.locationName,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String displayImagePath = imagePath ?? _getDefaultImage(locationName);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: hexToColor(guardColors[0]),
        title: Text(
          locationName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Location Image
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(displayImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Location Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              locationName,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),

          // "Mark Empty" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ElevatedButton(
              onPressed: () => _markLocationAsEmpty(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: hexToColor(guardColors[2]),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Mark Empty",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: ElevatedButton(
              onPressed: () => _viewCurrentStudents(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: hexToColor(guardColors[2]),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "View Current Students",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDefaultImage(String location) {
    switch (location) {
      case "CS Block":
        return image_paths.cs_block;
      case "General Labs":
        return image_paths.cs_lab;
      case "Research Labs":
        return image_paths.research_lab;
      case "Lecture Rooms":
        return image_paths.lecture_room;
      case "Conference Room":
        return image_paths.conference_room;
      default:
        return image_paths.cs_block;
    }
  }

  void _markLocationAsEmpty(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm",
            style: GoogleFonts.poppins(color: Colors.red),
          ),
          content: Text(
            "Mark $locationName as empty?",
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Confirm",
                style: GoogleFonts.poppins(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await databaseInterface.markLocationEmpty(locationName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "$locationName marked as empty"
                : "Failed to mark location",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: success ? hexToColor(guardColors[2]) : Colors.red,
        ),
      );
    }
  }

  void _viewCurrentStudents(BuildContext context) async {
    final students = await databaseInterface.getCurrentStudents(locationName);
    print(locationName);
    print(students);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentStudentsPage(
          locationName: locationName,
          students: students,
        ),
      ),
    );
  }
}
