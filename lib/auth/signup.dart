import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/forgot_password.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSaved,
    this.controller,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 241, 241, 241),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.kodchasan(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name Field
                  CustomTextFormField(
                    labelText: "Full Name",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  CustomTextFormField(
                    labelText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextFormField(
                    labelText: "Password",
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  CustomTextFormField(
                    labelText: "Confirm Password",
                    obscureText: _obscureConfirmPassword,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: 250,
                    child: MaterialButton(
                      height: 65,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: const Color(0xFF827397),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Check if email ends with '@iitrpr.ac.in'
                          if (!_emailController.text.endsWith('@iitrpr.ac.in')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please use your IIT Ropar email address'),
                              ),
                            );
                            return;
                          }

                          // Send OTP for email verification and navigate to

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sign Up Successful!'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.kodchasan(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
