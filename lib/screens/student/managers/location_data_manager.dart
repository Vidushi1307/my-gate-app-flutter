import 'package:flutter/material.dart'; // For Colors and Color
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

class LocationDataManager {
  List<String> locations = [];
  List<int> locationIds = [];
  List<bool> preApprovals = [];
  List<int> occupantCounts = [];
  List<String> statuses = [];
  final List<String> location_images_paths =
      databaseInterface.getLocationImagesPaths();

  Future<void> loadData(String email) async {
    final result = await databaseInterface.getLoctionsAndPreApprovals();
    locations = result.locations;
    locationIds = result.location_id;
    preApprovals = result.preApprovals;

    // Load counts
    occupantCounts = await Future.wait(
        locationIds.map((id) => databaseInterface.count_inside_Location(id)));

    // Load statuses
    final statusMap = await databaseInterface
        .get_student_status_for_all_locations_2(email, locationIds);

    statuses = [
      statusMap['CS Block'] ?? 'NOT FOUND',
      statusMap['Lab 101'] ?? 'NOT FOUND',
      statusMap['Lab 102'] ?? 'NOT FOUND',
      statusMap['Lab 202'] ?? 'NOT FOUND',
      statusMap['Lab 203'] ?? 'NOT FOUND'
    ];
    print("Loading location data done");
  }

  String getImagePath(int index) {
    if (index < 6) return location_images_paths[index];
    return image_paths.spiral;
  }

  String? currentLocation;
  String currentStatus = "Not checked in";
  Color statusColor = Colors.grey;

  Future<void> updateCurrentStatus(String email) async {
    try {
      final statusMap = await databaseInterface
          .get_student_status_for_all_locations_2(email, locationIds);

      final activeEntry = statusMap.entries.firstWhere(
        (e) => e.key != 'CS Block' && e.value.toString() == 'in',
        orElse: () =>
            const MapEntry('No Registered Location', 'Not checked in'),
      );

      currentLocation = activeEntry.key;
      currentStatus = activeEntry.value;
      statusColor = _getStatusColor(activeEntry.value);
      statuses[0] = statusMap['CS Block'];
    } catch (e) {
      print("Error updating current status: $e");
      currentLocation = 'No Registered Location';
      currentStatus = 'ERROR';
      statusColor = Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'checked in':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'restricted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
