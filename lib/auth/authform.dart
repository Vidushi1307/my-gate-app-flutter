// ignore_for_file: unnecessary_new, sized_box_for_whitespace, deprecated_member_use, prefer_const_constructors, avoid_print, non_constant_identifier_names, unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/forgot_password.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/admin/home_admin.dart';
import 'package:my_gate_app/screens/authorities/authority_main.dart';
import 'package:my_gate_app/screens/guard/enter_exit.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/student/home_student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/myglobals.dart' as myglobals;

import 'dart:async';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final email_form_key = GlobalKey<FormState>();
  String snackbar_message = "";
  Color snackbar_message_color = Colors.white;

  final _formkey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _guard_location = '';
  var fetchedemail = '';
  int entered_otp = 459700;
  int otp_op = 1;
  bool countDownComplete = false;

  bool showOtpField = false;

  LoginResultObj is_authenticated = LoginResultObj("", "");

  // var _reentered_password = '';
  // var _username = '';
  // bool isLoginPage = false;
  bool _obscureText = true;
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

  Future<bool> forgot_password(int op) async {
    print("forgot password 1:$fetchedemail");
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String message =
        await databaseInterface.forgot_password(fetchedemail, op, entered_otp);
    print("forgot password 2:$fetchedemail");
    if (message == 'User email not found in database') {
      setState(() {
        snackbar_message = message;
        snackbar_message_color = Colors.red;
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    } else if (message == 'OTP sent to email') {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else if (message == 'OTP Matched') {
      setState(() {
        snackbar_message = message;
        snackbar_message_color = Colors.green;
      });

      /* print("Redirect to reset password");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ResetPassword(email: email)),
      ); */
      return true;
    } else if (message == 'OTP Did not Match') {
      setState(() {
        snackbar_message = message;
        snackbar_message_color = Colors.red;
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } else {
      setState(() {
        snackbar_message = message;
        snackbar_message_color = Colors.red;
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Login Fail',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  void LoginScaffold(String message) {
    print("@@ $message");
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (message == "Login Successful") {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (message == "user not found") {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else if (message == "Invalid username or password") {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            "Login Failed",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> startauthentication() async {
    final validity = _formkey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (validity != null && validity) {
      _formkey.currentState?.save();
      // Add basic checks for email and password in the frontend

      String message = await databaseInterface.jwt_login(_email, _password);
      LoginScaffold(message);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      is_authenticated.person_type = prefs.getString("type")!;
    }
  }

  Future<void> guardLocation() async {
    databaseInterface db = new databaseInterface();
    await db.get_guard_by_email(_email).then((GuardUser result) {
      setState(() {
        _guard_location = result.location;
        print("Result Location in Auth form${result.location}");
      });
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,

        // height: MediaQuery.of(context).size.height,
        // width: MediaQuery.of(context).size.width,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/authform.png"),
        //     // // image: Image.asset("assets/images/spiral3.png"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        // child: new BackdropFilter(
        //   filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        //   child: new Container(
        //     decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
        //   ),
        // ),

        child: ListView(
          children: [
            // Text(
            //   'Welcome to \nCampus-InOutMgmt\nIIT ROPAR',
            //   textAlign: TextAlign.center,
            //   style: GoogleFonts.nunitoSans(
            //     fontSize: 35,
            //     color: Color.fromARGB(255, 255, 255, 255),
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),

            Container(
              // decoration: BoxDecoration(
              //   color: Color.fromARGB(255, 255, 255, 255),
              //   borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(30),
              //     topRight: Radius.circular(30),
              //     bottomLeft: Radius.circular(30),
              //     bottomRight: Radius.circular(30),
              //   ),
              // ),
              color: Color.fromARGB(255, 255, 255, 255),
              // ignore: prefer_const_constructors
              // margin: EdgeInsets.only(
              //     bottom: 0.0, top: MediaQuery.of(context).size.height / 6),
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 14, bottom: 100),
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kodchasan(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 130),

                    Text(
                      "Let's SignIn",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kodchasan(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    //marked1
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      key: const ValueKey('email'),
                      // how does this work?
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid Email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        fetchedemail = value;
                      },
                      onSaved: (value) {
                        _email = value!;
                        /* fetchedemail = value!; */
                      },
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold), //mark1 end
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Change border color here
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Change border color here
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

                    SizedBox(
                      height: 20,
                    ),
                    //marked2
                    TextFormField(
                      obscureText: _obscureText,
                      keyboardType: TextInputType.emailAddress,
                      key: const ValueKey('password'),
                      // how does this work?
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password is empty';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _password = value;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                      //mark2end
                      // decoration: InputDecoration(

                      //   border: OutlineInputBorder(
                      //     borderRadius: new BorderRadius.circular(8.0),
                      //     borderSide: const BorderSide(),
                      //   ),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Change border color here
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Change border color here
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Change border color here
                        ),
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: _toggle,
                          child: new Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
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
                    // SizedBox(
                    //   height: 10,
                    // ),

                    // SubmitButton(
                    //   submit_function: () async {
                    //     /*  final email_validity =
                    //   this.email_form_key.currentState?.validate(); */
                    //     FocusScope.of(context).unfocus();
                    //     if (/* email_validity != null && email_validity */ true) {
                    //       print("Sending otp");
                    //       email_form_key.currentState?.save();
                    //
                    //       forgot_password(1);
                    //       print("Fetched Email=   $fetchedemail");
                    //       /* print("Fetched Email=   "+_email); */
                    //       print("otp sent to $fetchedemail");
                    //       setState(() {
                    //         otp_op = 2;
                    //         showOtpField = true;
                    //         startTimeout();
                    //         print("timer started");
                    //       });
                    //     }
                    //   },
                    //   button_text: "GET OTP",
                    // ),

                    SizedBox(
                      height: 10,
                    ),

                    // Visibility(
                    //   visible:
                    //       showOtpField, // show the OTP field only when showOtpField is true
                    //
                    //   child: OtpTextField(
                    //     numberOfFields: 6,
                    //     inputFormatters: <TextInputFormatter>[
                    //       FilteringTextInputFormatter.digitsOnly
                    //     ],
                    //
                    //     fieldWidth: (MediaQuery.of(context).size.width) / 10,
                    //     focusedBorderColor: Colors.black,
                    //     // defaultBorderColor: Colors.grey,
                    //     borderRadius: BorderRadius.circular(5),
                    //     showFieldAsBox: true,
                    //     textStyle: TextStyle(
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 20,
                    //     ),
                    //     keyboardType: TextInputType.number,
                    //     onSubmit: (String code) {
                    //       if (code.length == 6) {
                    //         entered_otp = int.parse(code);
                    //         print("entered otp set to: $entered_otp");
                    //       }
                    //     },
                    //   ),
                    // ),

                    SizedBox(
                      height: 10,
                    ),
                    //mark3
                    // Container(
                    //   child: TextButton(
                    //       onPressed: () {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //               builder: (context) => ForgotPassword()),
                    //         );
                    //         // forgot_password();
                    //       },
                    //       child: Text(
                    //         'Forgot Password?',
                    //         style: GoogleFonts.roboto(
                    //           fontSize: 15,
                    //           color: Colors.grey[700],
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       )),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 5),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ForgotPassword(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password',
                            style: GoogleFonts.kodchasan(
                              fontSize: 13, // Set the font size here
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //mark3end
                    SizedBox(
                      height: 20,
                    ),
                    //mark4
                    SizedBox(
                      width: 250.0,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        width: double.infinity,
                        height: 65,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(10),
                        // ),

                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color(0xFF827397),
                          onPressed: () async {
                            /*  final email_validity =
                    //   this.email_form_key.currentState?.validate(); */
                            FocusScope.of(context).unfocus();
                            // if (/* email_validity != null && email_validity */ true) {

                            //   email_form_key.currentState?.save();

                            //   forgot_password(1);
                            //   print("Fetched Email=   $fetchedemail");
                            //   /* print("Fetched Email=   "+_email); */
                            //   print("otp sent to $fetchedemail");
                            //   setState(() {
                            //     otp_op = 2;
                            //     showOtpField = true;
                            //     startTimeout();
                            //     print("timer started");
                            //   });
                            // }
                            // entered_otp=111111;
                            await startauthentication();
                            print(
                                "&&%## person_type: ${is_authenticated.person_type}");
                            if (is_authenticated.person_type == "Student") {
                              print("Inside Student");
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomeStudent(
                                        email: LoggedInDetails.getEmail())),
                              );
                              myglobals.auth!.login();
                            } else if (is_authenticated.person_type ==
                                "Guard") {
                              await guardLocation();
                              // print("Inside Guard");
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                  'guard_location', _guard_location);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => EntryExit(
                                          guard_location: _guard_location,
                                        )),
                              );
                            } else if (is_authenticated.person_type ==
                                "Authority") {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => AuthorityMain()),
                              );
                            } else if (is_authenticated.person_type ==
                                "Admin") {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomeAdmin()),
                              );
                            } else {
                              print("Login failed .... display snackbar");
                              LoginScaffold("Login Failed");
                            }
                          },
                          child: Text(
                            'SignIn',
                            style: GoogleFonts.kodchasan(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

//class RoundedRectangularBorder {}
