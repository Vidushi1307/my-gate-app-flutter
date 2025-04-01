import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';

import 'package:my_gate_app/get_email.dart';

class NotificationManager {
  int count = 0;
  Stream<int>? countStream;

  void initialize(String email) {
    countStream = databaseInterface.get_notification_count_stream(email);
  }

  Future<void> refreshCount(String email) async {
    count = await databaseInterface.return_total_notification_count_guard(email);
  }
}

