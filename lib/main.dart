// @dart=2.19
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_gate_app/notifier.dart';
import 'package:my_gate_app/splash.dart';
import 'package:provider/provider.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/admin/home_admin.dart';
import 'package:my_gate_app/screens/authorities/authority_main.dart';
import 'package:my_gate_app/screens/guard/enter_exit.dart';
import 'package:my_gate_app/screens/student/home_student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:my_gate_app/myglobals.dart' as myglobals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  myglobals.auth = AuthState();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: myglobals.auth, // Provide the global instance
      child: MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.green,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.red, //use your hex code here
            ),
          ),
          home: Home(),
          debugShowCheckedModeBanner: true),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final SharedPreferences prefs = snapshot.data!;
          final String? type = prefs.getString("type");
          final String? email = prefs.getString("email");
          final String? guardLocation = prefs.getString("guard_location");
          if (type != null) {
            print("type: $type");
          }
          if (email == null) {
            return Splash();
          } else if (type == "Student" && email != null) {
            LoggedInDetails.setEmail(email);
            return HomeStudent(email: email);
          } else if (type == "Authority" && email != null) {
            LoggedInDetails.setEmail(email);
            return AuthorityMain();
          } else if (type == "Admin" && email != null) {
            LoggedInDetails.setEmail(email);
            return HomeAdmin();
          } else if (type == "Guard" && email != null) {
            LoggedInDetails.setEmail(email);
            if (guardLocation != null) {
              return EntryExit(
                guard_location: guardLocation,
              );
            } else {
              return Splash();
            }
          } else {
            return Splash();
            // return Text('not intended try to uncomment above line');
          }
        } else {
          return Splash();
        }
      },
    );
  }
}
