import 'package:my_gate_app/database/database_interface.dart';

class OTPService {
  final databaseInterface db;

  OTPService(this.db);

  Future<String> sendOTP(String email) async {
    return await databaseInterface.forgot_password(email, 1, 0);
  }

  Future<String> verifyOTP(String email, int otp) async {
    return await databaseInterface.forgot_password(email, 2, otp);
  }
}
