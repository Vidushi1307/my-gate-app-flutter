import 'package:flutter/material.dart'; // For NetworkImage
import 'package:my_gate_app/screens/profile2/model/user.dart'; // For User
import 'package:my_gate_app/database/database_interface.dart'; // For databaseInterface
import 'package:my_gate_app/image_paths.dart' as image_paths;

/*class UserProfileManager {
  final String email;
  User user;
  ImageProvider? profileImage;
  final ValueNotifier<bool> updateNotifier = ValueNotifier(false);

  UserProfileManager({required this.email, required this.user});

  Future<void> loadProfile() async {
    final db = databaseInterface();
    user = await db.get_student_by_email(email);
    profileImage = NetworkImage(image_paths.dummy_person);
    updateNotifier.value = !updateNotifier.value;
  }
}*/


class UserProfileManager {
  User user;
  ImageProvider? profileImage; // Changed to general ImageProvider
  final ValueNotifier<bool> updateNotifier = ValueNotifier(false);

  UserProfileManager({
    required this.user,
    required String email,
  }) {
    _updateProfileImage();
  }

  void _updateProfileImage() {
    if (user.imagePath.startsWith('http')) {
      profileImage = NetworkImage(user.imagePath);
    } else if (user.imagePath.startsWith('assets/')) {
      profileImage = AssetImage(user.imagePath);
    } else {
      // Fallback to default asset
      profileImage = AssetImage(image_paths.dummy_person);
    }
  }

  Future<void> loadProfile(String email) async {
    final db = databaseInterface();
    user = await db.get_student_by_email(email);
    _updateProfileImage();
    print("Loading profile done");
  }
}
