// ignore_for_file: avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_constructors, unnecessary_this

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/otp_timer.dart';
import 'package:my_gate_app/auth/resest_password.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter/services.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // TODO get both these fields from frontend
  final email_form_key = GlobalKey<FormState>();
  String email = "mygateapp2022@gmail.com";
  int entered_otp = 459700;
  int otp_op = 1;
  bool countDownComplete = false;
  String snackbar_message = "";
  Color snackbar_message_color = Colors.white;

  Future<void> forgot_password(int op) async {
    print("forgot password 1:${this.email}");
    String message =
        await databaseInterface.forgot_password(email, op, entered_otp);
    print("forgot password 2:${this.email}");
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
      print("Redirect to reset password");
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
          //print(timer.tick);
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
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "OTP Verification",
              style: GoogleFonts.kodchasan(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30),
            ),
            SizedBox(
              height: 150,
            ),
            if (this.otp_op == 1)
              // TextBoxCustom(
              //   labelText: "Email",
              //   onSavedFunction: (value) {
              //     this.email = value!;
              //   },
              //   icon: const Icon(
              //     Icons.email_outlined,
              //     color: Colors.black,
              //   ),
              //   form_key: this.email_form_key,
              // ),
              Form(
                key: this.email_form_key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        key: const ValueKey('email'),
                        // how does this work?
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Invalid Email';
                          }
                          return null;
                        },

                        onSaved: (value) {
                          this.email = value!;
                          /* fetchedemail = value!; */
                        },
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold), //mark1 end
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color:
                                    Colors.black), // Change border color here
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color:
                                    Colors.black), // Change border color here
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(255, 241, 241, 241),
                          hintStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                          suffixStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Other widgets...
                  ],
                ),
              ),
            if (this.otp_op == 1)
              // SubmitButton(
              //   submit_function: () async {
              //     final email_validity =
              //         this.email_form_key.currentState?.validate();
              //     FocusScope.of(context).unfocus();
              //     if (email_validity != null && email_validity) {
              //       print("Sending otp");
              //       this.email_form_key.currentState?.save();
              //       forgot_password(1);
              //       print("otp sent to ${this.email}");
              //       setState(() {
              //         this.otp_op = 2;
              //         startTimeout();
              //         print("timer started");
              //       });
              //     }
              //   },
              //   button_text: "Get OTP",
              //
              // ),
              SizedBox(
                width: 250.0,
                child: Container(
                  padding: EdgeInsets.all(12),
                  height: 65,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Color(0xFF827397),
                    onPressed: () async {
                      final email_validity =
                          this.email_form_key.currentState?.validate();
                      FocusScope.of(context).unfocus();
                      if (email_validity != null && email_validity) {
                        print("Sending otp");
                        this.email_form_key.currentState?.save();
                        forgot_password(1);
                        print("otp sent to ${this.email}");
                        setState(() {
                          this.otp_op = 2;
                          startTimeout();
                          print("timer started");
                        });
                      }
                    },
                    child: Text(
                      'Get OTP',
                      style: GoogleFonts.kodchasan(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (this.otp_op == 2)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: OtpTextField(
                  numberOfFields: 6,
                  fieldWidth: (MediaQuery.of(context).size.width) / 10,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  focusedBorderColor: Colors.black,
                  // defaultBorderColor: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                  showFieldAsBox: true,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  keyboardType: TextInputType.number,
                  onSubmit: (String code) {
                    if (code.length == 6) {
                      this.entered_otp = int.parse(code);
                      print("entered otp set to: ${this.entered_otp}");
                    }
                  },
                ),
              ),
            if (this.otp_op == 2)
              // SubmitButton(
              //   submit_function: () async {
              //     await forgot_password(2);
              //   },
              //   button_text: "Verify OTP",
              // ),
              SizedBox(
                width: 250.0,
                child: Container(
                  padding: EdgeInsets.all(12),
                  height: 65,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Color(0xFF827397),
                    onPressed: () async {
                      await forgot_password(2);
                    },
                    child: Text(
                      'Verify OTP',
                      style: GoogleFonts.kodchasan(
                        fontSize: 25,
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
                  // print("here");
                },
                child: const Text("Resend OTP"),
              ),
            if (this.otp_op == 2) OtpTimer(),
            Text(this.snackbar_message,
                style: TextStyle(color: this.snackbar_message_color))
          ],
        ),
      ),
    );
  }
}
