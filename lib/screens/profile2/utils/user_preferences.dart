import 'package:flutter/cupertino.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';

class UserPreferences {
  static const myUser = User(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    profileImage: NetworkImage('https://i.imgflip.com/1myuho.jpg'),
    name: 'Loading...',
    email: 'Loading...',
    phone: 'Loading...',
    degree: 'Loading...',
    department: 'Loading...',
    year_of_entry: 'Loading...',
    gender: 'Loading...',
    isDarkMode: true,
  );

  static const myGuardUser = GuardUser(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    name: 'Loading...',
    email: 'Loading...',
    location: 'Loading...',
    isDarkMode: true,
  );

  static const myAuthorityUser = AuthorityUser(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    name: 'Loading...r',
    email: 'Loading...',
    designation: 'Loading...',
    isDarkMode: true,
  );

  static const myAdminUser = AdminUser(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    name: 'Loading...',
    email: 'Loading...',
    isDarkMode: true,
  );
}
