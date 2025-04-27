import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/forgot_password.dart';
import 'package:my_gate_app/auth/otp_service.dart';
import 'package:my_gate_app/auth/otp_timer.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool floatLabel; // Add this parameter to control floating behavior



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
    this.floatLabel = true, // Default to true for floating labels
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
          color:  Colors.grey // Focused color
        ),
        floatingLabelBehavior: floatLabel ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(30.0),
        //   borderSide: const BorderSide(color: Colors.black),
        // ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.grey),


        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 241, 241, 241),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
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
  bool _useEmailLogin = false;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _entryNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
 


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final OTPService _otpService = OTPService(databaseInterface());
  bool _otpVerified = false;
  String _otp = '';
  bool _otpSent = false;



  @override
  void dispose() {
    _nameController.dispose();
    _entryNoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (!_otpVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify OTP first')),
        );
        return;
      }

      try {
        var entryNo = _entryNoController.text;
        var email = _emailController.text;
        if (_useEmailLogin) {
          entryNo = _emailController.text.split('@').first;
        } else {
          email = '$entryNo@iitrpr.ac.in';
        }

        final result = await _otpService.registerUser(
          entryNo: entryNo,
          email: email,
          name: _nameController.text,
          password: _passwordController.text,
          // Add any other required fields
        );

        if (result == 'Registration successful') {
          // Navigate to home screen or show success message
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if entryNo ends with '@iitrpr.ac.in'
      // if (!_entryNoController.text.endsWith('@iitrpr.ac.in')) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Please use your IIT Ropar entryNo address'),
      //     ),
      //   );
      //   return;
      // }

      // Check if entryNo is valid  (of form NNNNXXXNNNN where N is a digit and X is a letter)
      // final RegExp entryNoRegex = RegExp(r'^[0-9]{4}[A-Za-z]{3}[0-9]{4}$');
      var entryNo = _entryNoController.text;
      var email = _emailController.text;
      if (_useEmailLogin) {
        entryNo = _emailController.text.split('@').first;
      } else {
        email = '$entryNo@iitrpr.ac.in';
        // if (!entryNoRegex.hasMatch(entryNo)) {
        //   // ScaffoldMessenger.of(context).showSnackBar(
        //   // const SnackBar(
        //   //   content: Text('Please enter a valid entry number'),
        //   // ),
        //   // );
        //   return;
        // }
      }

      // var email = '${_entryNoController.text}@iitrpr.ac.in';
      final result = await _otpService.sendOTPforRegister(email);

      if (result == 'OTP sent to email') {
        setState(() {
          _otpSent = true;
          _otpVerified = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $result')),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }
    var entryNo = _entryNoController.text;
    var email = _emailController.text;
    if (_useEmailLogin) {
      entryNo = _emailController.text.split('@').first;
    } else {
      email = '$entryNo@iitrpr.ac.in';
    }
    final result =
        await _otpService.verifyOTPforRegister(email, int.parse(_otp));
    if (!mounted) return;
    if (result == 'OTP Matched') {
      setState(() => _otpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified successfully')),
      );

      // Proceed with the sign-up process
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed: $result')),
      );
    }
  }

  Widget _buildOTPVerification() {
    return Column(
      children: [
        const SizedBox(height: 20),
        OtpTextField(
          numberOfFields: 6,
          fieldWidth: 40,
          onSubmit: (code) => _otp = code,
          // Add your OTP field styling here
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _verifyOTP,
          child: const Text('Verify OTP'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 30), // Reduced from default
                      child: Image.asset(
                        //'assets/images/new_splash_logo.webp',
                        'assets/images/Logo_update.png',
                        height: MediaQuery.of(context).size.height * 0.20, // Smaller logo
                        fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10), // Reduced spacing

                  Text(
                    'Create Account',
                    style: GoogleFonts.gabarito(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name Field
                  CustomTextFormField(
                    labelText: "Full Name",
                    controller: _nameController,
                    floatLabel: false, // This prevents the label from floating
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text('Use Email instead?'),
                  //     Switch(
                  //       value: _useEmailLogin,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _useEmailLogin = value;
                  //         });
                  //       },
                  //       activeColor: Color.fromARGB(255, 53, 147, 254),
                  //       activeTrackColor: Color.fromARGB(255, 144, 196, 255),
                  //       inactiveThumbColor: Colors.grey[400],
                  //       inactiveTrackColor: Colors.grey[300],
                  //     ),
                  //   ],
                  // ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Use Email instead?',
                        style: GoogleFonts.mulish(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: 1.3,
                        child: Switch(
                          value: _useEmailLogin,
                          onChanged: (value) {
                            setState(() {
                              _useEmailLogin = value;
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          activeColor: const Color(0xFF3593FE), // Blue when on
                          activeTrackColor: Color.fromARGB(255, 144, 196, 255),
                          inactiveThumbColor: Colors.grey[400],
                          inactiveTrackColor: Colors.grey[300],
                          splashRadius: 20,
                          thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Icon(
                                  Icons.account_circle_sharp,
                                  color: Colors.white,
                                  size: 14,
                                );
                              }
                              return const Icon(
                                Icons.account_circle_sharp,
                                color: Colors.white,
                                size: 14,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),



                  _useEmailLogin
                      ? CustomTextFormField(
                          labelText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          floatLabel: false, // This prevents the label from floating
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        )
                      : CustomTextFormField(
                          labelText: "Entry Number",
                          controller: _entryNoController,
                          floatLabel: false, // This prevents the label from floating
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your entry number';
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
                    floatLabel: false, // This prevents the label from floating
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
                    floatLabel: false, // This prevents the label from floating
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

                  // Send OTP Button
                  SizedBox(
                    width: 170,
                    child: MaterialButton(
                      height: 65,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: const Color.fromARGB(255, 53, 147, 254),
                      onPressed: _sendOTP,
                      child: Text(
                        'Send OTP',
                        style: GoogleFonts.kodchasan(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Show OTP verification if OTP has been sent
                  if (_otpSent) _buildOTPVerification(),

                  // Complete Sign Up Button (only shown after OTP verification)
                  if (_otpVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Complete Sign Up'),
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
