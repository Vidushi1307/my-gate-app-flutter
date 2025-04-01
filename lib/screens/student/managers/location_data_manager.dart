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
      'CS Block',
      'General Labs',
      'Research Labs',
      'Lecture Rooms',
      'Conference Rooms'
    ].map((key) => statusMap[key] ?? "DEFAULT_VALUE").cast<String>().toList();
  }

  String getImagePath(int index) {
    if (index < 6) return location_images_paths[index];
    return image_paths.spiral;
  }
}
