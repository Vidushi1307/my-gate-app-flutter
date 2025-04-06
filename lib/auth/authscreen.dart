// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_gate_app/auth/authform.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: AuthForm(),
    );
  }
}
