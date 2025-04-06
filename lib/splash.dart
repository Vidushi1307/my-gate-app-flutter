import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/authscreen.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                image_paths.splash,
                height: 300,
              ),
              Text(
                "SWIFT ENTRY",
                style: GoogleFonts.kodchasan(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.2),
          ],
        ),
      ),
    );
  }
}
