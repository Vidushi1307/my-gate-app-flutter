// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/admin/utils/file_upload_button.dart';

class UploadExcel extends StatefulWidget {
  const UploadExcel(
      {super.key,
      required this.upload_page_message,
      required this.upload_url,
      required this.upload_page_color});
  final String upload_page_message;
  final String upload_url;
  final Color? upload_page_color;

  @override
  _UploadExcelState createState() => _UploadExcelState();
}

class _UploadExcelState extends State<UploadExcel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // appBar: AppBar(
        //   title: Text('Manage Student'),
        //   actions: [IconButton(onPressed: () {}, icon: Icon(Icons.logout))],
        // ),
        body: Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     Color(0xFF212130),
              //     Color(0xFF39304A),
              //   ],
              // ),
              color: Color(0xfff0eded),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // color: widget.upload_page_color,
            child: Column(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  widget.upload_page_message,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 50,
                ),
                FileUploadButton(url_upload_file: widget.upload_url),
                SizedBox(
                  height: 50,
                ),
                // TextButton(
                //   child:Text('Fill Form'),
                //   onPressed: (){},
                // ),
              ],
            )));
  }
}
