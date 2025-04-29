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
import 'package:flutter/services.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

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
          backgroundColor: Colors.green,
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

  Future<bool> startauthentication() async {  // Changed return type to bool
    final validity = _formkey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (validity != null && validity) {
      _formkey.currentState?.save();
      
      String message = await databaseInterface.jwt_login(_email, _password);
      LoginScaffold(message);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) return false;  // Early exit if no token
      
      // Verify token hasn't expired
      final expiry = DateTime.parse(prefs.getString('accessTokenExpiry')!);
      if (expiry.isBefore(DateTime.now())) {
        await prefs.remove('accessToken');
        return false;
      }

      String? type = prefs.getString("type");
      if (type != null) {
        is_authenticated.person_type = type;
        return true;  // Only return true if everything succeeded
      }
    }
    return false;
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
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Container(
              color: Colors.black,//Color.fromARGB(255, 255, 255, 255),
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, //.center
                  children: [

                    // // Optimized logo
                    // Image.asset(
                    //   'assets/images/new_splash_logo.webp',
                    //   height: MediaQuery.of(context).size.height * 0.20,
                    // ),
                    // SizedBox(height: 15),
                    // // ------

                    Padding(
                      padding: const EdgeInsets.only(top: 25), // Reduced from default
                      child: Image.asset(
                        //'assets/images/new_splash_logo.webp',
                        'assets/images/Logo_update.png',
                        height: MediaQuery.of(context).size.height * 0.20, // Smaller logo
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10), // Reduced spacing

                    // Text(
                    //   'Welcome to Insight!',
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.gabarito(
                    //     fontSize: 10,
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.w800,
                    //   ),
                    // ),
                    
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.gabarito(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      children: [
                        TextSpan(text: 'Welcome to '),
                        TextSpan(text: 'Insight', style: TextStyle(color: const Color.fromARGB(255, 53, 147, 254))), // Different style for exclamation
                      ],
                      ),
                    ),

                    SizedBox(height: 60),

                    // Text(
                    //   "Your Department's Digital Gatekeeper",
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.notoSans(
                    //     fontSize: 10,
                    //     color: Colors.grey,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    // SizedBox(
                    //   height: 60,
                    // ),
                    

                    //marked1
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85, // 80% of screen width
                      child: TextFormField(
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
                            borderRadius: new BorderRadius.circular(30.0),
                            borderSide: const BorderSide(),
                          ),
                          // enabledBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(8.0),
                          //   borderSide: const BorderSide(
                          //       color: Colors.black), // Change border color here
                          // ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                 color: Colors.grey), // Change border color here
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never, // Add this line
                          filled: true,
                          fillColor: Colors.grey[200], //Color.fromARGB(255, 241, 241, 241)
                          hintStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                          suffixStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //marked2

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85, // 80% of screen width
                      child: TextFormField(
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
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                            color: Colors.black), // Change border color here
                          ),
                          // enabledBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(8.0),
                          //   borderSide: const BorderSide(
                          //       color: Colors.black), // Change border color here
                          // ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.grey), // Change border color here
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.grey[500],
                            // fontWeight: FontWeight.bold,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never, // Add this line
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
                              vertical: 17.0, horizontal: 16.0),
                        ),
                      ),
                    ),

                    SizedBox(
                          height: 25,
                        ),
                    

                    //mark4
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 550.0,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            width: double.infinity,
                            height: 75,
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              color: const Color.fromARGB(255, 53, 147, 254),  //Color.fromARGB(255, 140, 63, 126),//Color.fromARGB(255, 62, 18, 87), // Color.fromARGB(255, 53, 147, 254), 
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
                                'LOGIN',
                                style: GoogleFonts.gabarito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),
                      

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SizedBox(width: 5),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPassword(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.gabarito(
                                  fontSize: 17, // Set the font size here
                                  color: const Color.fromARGB(255, 53, 147, 254), //Color.fromRGBO(140, 63, 126, 1), //Color.fromARGB(255, 62, 18, 87), //
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //mark3end
                        // SizedBox(
                        //   height: 100,
                        // ),

                        // "Don't have an account?" text with Sign Up button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.mulish(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(text: "Don't have an account? "),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => SignUpScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Register!',
                                        style: GoogleFonts.mulish(
                                          fontSize: 16,
                                          color: const Color.fromARGB(255, 53, 147, 254), //Color.fromARGB(255, 140, 63, 126), //Color.fromARGB(255, 62, 18, 87), //Color.fromARGB(255, 53, 147, 254)
                                          fontWeight: FontWeight.w800
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
