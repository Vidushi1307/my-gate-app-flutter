import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/admin/utils/file_upload_button.dart';

class UploadInvalidEmail extends StatefulWidget {
  const UploadInvalidEmail({super.key});

  @override
  _UploadInvalidEmailState createState() => _UploadInvalidEmailState();
}

class _UploadInvalidEmailState extends State<UploadInvalidEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.amber,
            child:const Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Upload excel file having student emails to be disabled",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                      fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 50,
                ),
                FileUploadButton(url_upload_file: "http://127.0.0.1:8000/delete_students_from_file"),
              ],
            )
        )
    );
  }
}
