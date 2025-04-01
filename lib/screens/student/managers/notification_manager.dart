import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';

import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/database/database_interface.dart';

class NotificationManager {
  final String email;
  Stream<int>? _cachedStream;
  int count = 0; // Add this line to store the count

  NotificationManager(this.email);

  Stream<int> get notificationStream {
    _cachedStream ??= databaseInterface
        .get_notification_count_stream(email)
        .asBroadcastStream();
    return _cachedStream!;
  }

  // Renamed from initialize to refreshCount
  Future<void> refreshCount() async {
    final newCount = await databaseInterface.return_total_notification_count_guard(email);
    count = newCount; // Update the count
    print("Refresh notifications done");
  }
}
