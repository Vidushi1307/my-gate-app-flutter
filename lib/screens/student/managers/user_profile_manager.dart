import 'package:flutter/material.dart'; // For NetworkImage
import 'package:my_gate_app/screens/profile2/model/user.dart'; // For User
import 'package:my_gate_app/database/database_interface.dart'; // For databaseInterface

class UserProfileManager {
  final String email;
  User user;
  NetworkImage? profileImage;
  final ValueNotifier<bool> updateNotifier = ValueNotifier(false);

  UserProfileManager({required this.email, required this.user});

  Future<void> loadProfile() async {
    final db = databaseInterface();
    user = await db.get_student_by_email(email);
    profileImage = NetworkImage(user.imagePath);
    updateNotifier.value = !updateNotifier.value;
  }
}

