import 'package:flutter/material.dart'; // For NetworkImage
import 'package:my_gate_app/screens/profile2/model/user.dart'; // For User
import 'package:my_gate_app/database/database_interface.dart'; // For databaseInterface
import 'package:my_gate_app/image_paths.dart' as image_paths;

class UserProfileManager {
  User user;
  ImageProvider? profileImage; // Changed to general ImageProvider
  final ValueNotifier<bool> updateNotifier = ValueNotifier(false);

  UserProfileManager({
    required this.user,
    required String email,
  }) {
    updateProfileImage();
  }

  void updateProfileImage() {
    if (user.imagePath.startsWith('assets/')) {
      profileImage = AssetImage(user.imagePath);
    } else if (user.imagePath.startsWith('http')) {  // Handle network images
      profileImage = NetworkImage(user.imagePath);
    } else {  // Fallback
      profileImage = AssetImage(image_paths.dummy_person);
    }
  }
  Future<void> loadProfile(String email) async {
    final db = databaseInterface();
    user = await databaseInterface.get_student_by_email(email);
    updateProfileImage();
    print("Loading profile done");
  }
}
