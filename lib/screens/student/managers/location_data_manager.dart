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
    // final result = await databaseInterface.getLoctionsAndPreApprovals();
    // locations = result.locations;
    // locationIds = result.location_id;
    // preApprovals = result.preApprovals;

    // // Load counts
    // occupantCounts = await Future.wait(
    //     locationIds.map((id) => databaseInterface.count_inside_Location(id)));

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
    if (statusMap['Lab 101'] == 'in')
      currentLocation = "Lab 101";
    else if (statusMap['Lab 102']  == 'in')
      currentLocation = "Lab 102";
    else if (statusMap['Lab 202']  == 'in')
      currentLocation = "Lab 202";
    else if (statusMap['Lab 203']  == 'in')
      currentLocation = "Lab 203";

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
      print("db call successful:");
      print(statusMap);
      statuses = [
        statusMap['CS Block'] ?? 'NOT FOUND',
        statusMap['Lab 101'] ?? 'NOT FOUND',
        statusMap['Lab 102'] ?? 'NOT FOUND',
        statusMap['Lab 202'] ?? 'NOT FOUND',
        statusMap['Lab 203'] ?? 'NOT FOUND'
      ];      
      
      statuses[0] = statusMap['CS Block'] ?? "UNKNOWN";
      if (statusMap['CS Block'] == 'in'){
        print("Inside CS Block");
        if (statusMap['Lab 101'] == 'in'){
          currentLocation = 'Lab 101';
          print("Checked for 101");
          return;          
        } 
        if (statusMap['Lab 102'] == 'in'){
          currentLocation = 'Lab 102';
          print("Checked for 102");        
          return;
        } 
        if (statusMap['Lab 202'] == 'in'){
          currentLocation = 'Lab 202';
          print("Checked for 202");
          return;
        } 
        if (statusMap['Lab 203'] == 'in'){
          currentLocation = 'Lab 203';
          print("Checked for 203");        
          return;
        }
        print("Not in any location though");
        print(statusMap);
        return;
      }
      else {
        currentLocation = 'No Registered Location';
        currentStatus = 'Not checked in';
        statusColor = Colors.grey;
      }
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
