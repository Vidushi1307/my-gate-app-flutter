import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/authscreen.dart';

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
                'assets/new_images/new_splash_logo.png',
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
    return Scaffold(
      body: Container(
        color: Colors.black,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.jpg"),
            // fit: BoxFit.cover,
          ),
        ),
        // child: Text(
        //   "My Gate",
        //   style: TextStyle(
        //     // fontSize: 24,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ) /* add child content here */,
      ),
    );
    // return Scaffold(
    //   body: Center(
    //     child: Container(
    //       child: Text(
    //         'My Gate',
    //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //   ),
    // );
  }
}
