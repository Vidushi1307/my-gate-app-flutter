// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_init_to_null, avoid_print

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

class FileUploadButton extends StatefulWidget {
  const FileUploadButton({super.key, required this.url_upload_file});
  final String url_upload_file;
  @override
  State<FileUploadButton> createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  String chosen_file_message = "No file chosen";
  String upload_file_message = "";
  Uint8List? chosen_file = null;

  databaseInterface db = databaseInterface();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 143, 158, 1),
                      Color.fromRGBO(255, 188, 143, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    )
                  ]),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.file_copy_outlined,
                  color: Colors.white70,
                  size: 45.0,
                ),
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.grey),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                        ))),
                onPressed: () async {
                  FilePickerResult? picked =
                      await FilePicker.platform.pickFiles();
                  if (picked != null) {
                    print(picked.files.first.name);
                    print(picked.files.first.extension);
                    if (picked.files.first.extension == 'csv') {
                      chosen_file = picked.files.first.bytes;

                      setState(() {
                        chosen_file_message =
                            "File: ${picked.files.first.name}";
                      });
                    } else if (picked.files.first.extension != 'csv') {
                      setState(() {
                        chosen_file_message =
                            """Incorrect file uploaded.\nKindly upload csv file""";
                      });
                      final snackBar = get_snack_bar(
                          "Incorrect file uploaded.\nKindly upload csv file",
                          Colors.red);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                },
                label: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                      margin: EdgeInsets.all(30),
                      height: 100,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Text(
                        'Choose',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 50),
                      )
                  ),
                ),
              ),
            ),
          ),
          Text(
            chosen_file_message,
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            padding: EdgeInsets.all(15),
            //color: Colors.green,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 143, 158, 1),
                      Color.fromRGBO(255, 188, 143, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    )
                  ]),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.upload_file,
                  color: Colors.white70,
                  size: 45.0,
                ),
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.grey),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            ))),
                onPressed: () {
                  try {
                    if (chosen_file != null) {
                      setState(() {
                        upload_file_message = "File uploaded";
                        db.send_file(chosen_file, widget.url_upload_file);
                        final snackBar =
                            get_snack_bar("File uploaded", Colors.green);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    } else {
                      setState(() {
                        upload_file_message = "Kindly choose a csv file";
                        final snackBar = get_snack_bar(
                            "Kindly choose a csv file", Colors.red);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    }
                  } catch (e) {
                    print(e.toString());
                    setState(() {
                      upload_file_message = "Error: choose a csv file";
                      final snackBar =
                          get_snack_bar("Kindly choose a csv file", Colors.red);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  }
                },
                label: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                      margin: EdgeInsets.all(30),
                      height: 100,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Text(
                        'Upload',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 50),
                      )
                      ),
                ),
              ),
            ),
          ),
          Text(
            upload_file_message,
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
