import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_app/get_email.dart';

class ChangeLocationPage extends StatefulWidget {
  @override
  _ChangeLocationPageState createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends State<ChangeLocationPage> {
  final List<String> locations = [
    'Lab 101',
    'Lab 102',
    'Lab 202',
    'Lab 203'
  ];
  String? selectedLocation;
  String purpose = '';
  bool isLoading = false;
  String statusMessage = '';

  final _formKey = GlobalKey<FormState>();

  Future<String?> _getEmail() async {
    databaseInterface db = databaseInterface();
    String email = LoggedInDetails.getEmail();
    return email;
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && selectedLocation != null) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
        statusMessage = '';
      });

      String? email = await _getEmail();
      if (email == null) {
        setState(() {
          isLoading = false;
          statusMessage = 'User email not found. Please log in.';
        });
        return;
      }

      String response = await databaseInterface.updateLocationStatus(
        email: email,
        newLocation: selectedLocation!,
        purpose: purpose,
      );
      setState(() {
        isLoading = false;
        statusMessage = response;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location and enter a purpose')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // White header
        title: Text(
          'Change Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Black title text
        ),
        iconTheme:
            IconThemeData(color: Colors.white), // Back button/icon in black
      ),
      backgroundColor: Colors.black, // White background
      body: Stack(
        children: [
          // Black background (top 60%)
          // Black background (top 60%)
          Align(
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Logo positioned at top
                  Positioned(
                    top: -80, // Small padding from top
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/cl.png',
                        height: MediaQuery.of(context).size.height * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Centered "Change Location" text
                  // Center(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 20), // Adjust this to move text lower
                  //     child: Text(
                  //       'Change Location',
                  //       style: TextStyle(
                  //         fontSize: 30,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // White frame (bottom 40%)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child : Padding(
                padding: EdgeInsets.all(30.0),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Location',
                                labelStyle:
                                    TextStyle(color: Colors.black), // Label in black
                                    
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black), // Black border
                                      borderRadius: BorderRadius.circular(30.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              items: locations.map((location) {
                                return DropdownMenuItem(
                                    value: location,
                                    child: Text(location,
                                        style: TextStyle(color: Colors.black)));
                              }).toList(),
                              style: TextStyle(color: Colors.black),
                              value: selectedLocation,
                              onChanged: (value) {
                                setState(() {
                                  selectedLocation = value;
                                });
                              },
                              dropdownColor: Colors.white,
                              validator: (value) =>
                                  value == null ? 'Please select a location' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Purpose',
                                labelStyle:
                                    TextStyle(color: Colors.black), // Label in black
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              style: TextStyle(color: Colors.grey), // Input text black
                              onSaved: (value) => purpose = value!,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter purpose'
                                  : null,
                            ),
                            SizedBox(height: 20),
                            // ElevatedButton(
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Color.fromARGB(255, 53, 147, 254), // Black button
                            //     foregroundColor: Colors.white, // White text
                            //   ),
                            //   onPressed: _submit,
                            //   child: Text('Submit'),
                            // ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 53, 147, 254),
                                foregroundColor: Colors.white,
                                minimumSize: Size(MediaQuery.of(context).size.width * 2.0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _submit,
                              child: Text('Submit'),
                            ),
                            SizedBox(height: 20),
                            Text(statusMessage, style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
              ),
            ),
          ),   
        ], 
      ),
    );
  }
}

