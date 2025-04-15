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

  Future<String> sendOTPforRegister(String email) async {
    return await databaseInterface.forgot_password(email, 3, 0);
  }

  Future<String> verifyOTPforRegister(String email, int otp) async {
    return await databaseInterface.forgot_password(email, 4, otp);
  }

  Future<String> registerUser({
    required String entryNo,
    required String name,
    required String password,
  }) async {
    return await databaseInterface.registerUser(
      entryNo: entryNo,
      name: name,
      password: password,
    );
  }
}
