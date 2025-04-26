// ignore_for_file: unnecessary_new, sized_box_for_whitespace, deprecated_member_use, prefer_const_constructors, avoid_print, non_constant_identifier_names, unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/forgot_password.dart';
import 'package:my_gate_app/auth/signup.dart';
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

  bool _obscureText = true;
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

  Future<bool> forgot_password(int op) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String message =
        await databaseInterface.forgot_password(fetchedemail, op, entered_otp);
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
          backgroundColor: const Color.fromRGBO(255, 204, 53, 1),
        ),
      );
      return true;
    } else if (message == 'OTP Matched') {
      setState(() {
        snackbar_message = message;
        snackbar_message_color = const Color.fromRGBO(255, 204, 53, 1);
      });

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
          backgroundColor: const Color.fromRGBO(254,204,53,1),
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

      String message = await databaseInterface.jwt_login(_email, _password);
      LoginScaffold(message);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? type = prefs.getString("type");
      if (type != null) {
        is_authenticated.person_type = type;
      }
    }
  }

  Future<void> guardLocation() async {
    databaseInterface db = new databaseInterface();
    await db.get_guard_by_email(_email).then((GuardUser result) {
      setState(() {
        _guard_location = result.location;
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
        child: ListView(
          children: [
            Container(
              color: Color.fromARGB(255, 255, 255, 255),
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
                    SizedBox(height: 50),

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

                    // SizedBox(
                    //   height: 10,
                    // ),
                    // //mark3
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
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color(0xFF827397),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await startauthentication();
                            if (is_authenticated.person_type == "Student") {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomeStudent(
                                        email: LoggedInDetails.getEmail())),
                              );
                              myglobals.auth!.login();
                            } else if (is_authenticated.person_type ==
                                "Guard") {
                              await guardLocation();
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

                    // SignUp Button
                    SizedBox(
                      width: 250.0,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        width: double.infinity,
                        height: 65,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color(0xFF827397), // Same color as SignIn
                          onPressed: () {
                             Navigator.of(context).push(
                               MaterialPageRoute(
                                 builder: (context) => SignUpScreen(),
                               ),
                             );
                          },
                          child: Text(
                            'Sign Up',
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
