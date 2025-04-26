// ignore_for_file: avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_constructors, unnecessary_this

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/otp_timer.dart';
import 'package:my_gate_app/auth/reset_password.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter/services.dart';
import 'package:my_gate_app/auth/otp_service.dart';
import 'package:my_gate_app/image_paths.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final OTPService _otpService = OTPService(databaseInterface());
  final email_form_key = GlobalKey<FormState>();
  String email = "mygateapp2022@gmail.com";
  int entered_otp = 459700;
  int otp_op = 1;
  bool countDownComplete = false;
  String snackbar_message = "";
  Color snackbar_message_color = Colors.white;

  Future<void> forgot_password(int op) async {
    String message;
    if (op == 1) {
      message = await _otpService.sendOTP(email);
      if (message == 'OTP sent to email') {
        setState(() => otp_op = 2);
      }
    } else {
      message = await _otpService.verifyOTP(email, entered_otp);
    }
    if (message == 'User email not found in database') {
      setState(() {
        this.snackbar_message = message;
        this.snackbar_message_color = Colors.red;
      });
    } else if (message == 'OTP sent to email') {
    } else if (message == 'OTP Matched') {
      setState(() {
        this.snackbar_message = message;
        this.snackbar_message_color = Colors.green;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ResetPassword(email: email)),
      );
    } else if (message == 'OTP Did not Match') {
      setState(() {
        this.snackbar_message = message;
        this.snackbar_message_color = Colors.red;
      });
    } else {
      setState(() {
        this.snackbar_message = message;
        this.snackbar_message_color = Colors.red;
      });
    }
  }

  startTimeout() {
    const interval = Duration(seconds: 1);
    var duration = interval;
    int currentSeconds = 0;
    int timerMaxSeconds = 120;
    Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          currentSeconds = timer.tick;
          if (currentSeconds >= timerMaxSeconds) {
            setState(() {
              countDownComplete = true;
            });
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.09),

              Image.asset(
                logo,
                height: 185,
                width: 185,
              ),

              SizedBox(height: screenHeight * 0.08),

              if (this.otp_op == 1)
                Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'We will send you an One Time Passcode',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'via this email address',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),

              if (this.otp_op == 1)
                Form(
                  key: this.email_form_key,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: TextFormField(
                          cursorColor: Color.fromARGB(255, 53, 147, 254),
                          keyboardType: TextInputType.emailAddress,
                          key: const ValueKey('email'),
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Invalid Email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            this.email = value!;
                          },
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            labelText: "Enter your email",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintStyle: TextStyle(color: Colors.grey[800]),
                            suffixStyle: TextStyle(color: Colors.grey[800]),
                            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),

                            // 🔥 HOT RED for error message
                            errorStyle: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.redAccent,
                                width: 1.5, // <-- thicker border
                              ),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.redAccent,
                                width: 1.5, // <-- thicker border even when focused
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never, // This removes the label when focused
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (this.otp_op == 1)
                Container(
                  width: 200,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: screenHeight * 0.03),
                  child: MaterialButton(
                    height: 60,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Color.fromARGB(255, 53, 147, 254),
                    onPressed: () async {
                      final email_validity =
                          this.email_form_key.currentState?.validate();
                      FocusScope.of(context).unfocus();
                      if (email_validity != null && email_validity) {
                        this.email_form_key.currentState?.save();
                        forgot_password(1);
                        setState(() {
                          this.otp_op = 2;
                          startTimeout();
                        });
                      }
                    },
                    child: Text(
                      'Get OTP',
                      style: GoogleFonts.kodchasan(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              if (this.otp_op == 2)
                Column(
                  children: [
                    SizedBox(height: screenHeight * 0.12),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: screenHeight * 0.03),
                      child: OtpTextField(
                        numberOfFields: 6,
                        fieldWidth: (MediaQuery.of(context).size.width) / 8.5,
                        cursorColor: Color.fromARGB(255, 53, 147, 254),
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        focusedBorderColor: Colors.white, // Prevent the border color change
                        borderRadius: BorderRadius.circular(5),
                        showFieldAsBox: true,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        keyboardType: TextInputType.number,
                        onSubmit: (String code) {
                          if (code.length == 6) {
                            this.entered_otp = int.parse(code);
                          }
                        },
                      ),
                    ),
                  ],
                ),

              if (this.otp_op == 2)
                SizedBox(
                  width: 200.0,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    height: 65,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: Color.fromARGB(255, 53, 147, 254),
                      onPressed: () async {
                        await forgot_password(2);
                      },
                      child: Text(
                        'Verify OTP',
                        style: GoogleFonts.kodchasan(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              if (this.otp_op == 2)
                TextButton(
                  onPressed: () async {
                    if (this.countDownComplete) {
                      setState(() {
                        this.otp_op = 1;
                      });
                    }
                  },
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.mulish(
                      fontSize: 16,
                      color: Color.fromARGB(255, 53, 147, 254),
                      fontWeight: FontWeight.w800
                    ),
                  ),
                ),

              if (this.otp_op == 2) OtpTimer(),

              Text(this.snackbar_message,
                  style: TextStyle(color: this.snackbar_message_color)),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
