import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  addtasktofirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    String uid = user.uid;
    var time = DateTime.now();
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('mytasks')
        .doc(time.toString())
        .set({
      'title': titleController.text,
      'description': descriptionController.text,
      'time': time.toString(),
      'timestamp':time
    });
    Fluttertoast.showToast(msg: 'Data Added');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Enter Title', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Enter Description',
                    border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(backgroundColor:
                      WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      //return Colors.blueAccent.shade100;
                      return Theme.of(context).primaryColor.withOpacity(1);
                    } else {
                      return Theme.of(context).primaryColor;
                    }
                  })),
                  onPressed: () {
                    addtasktofirebase();
                  },
                  child: Text('Add Task',
                      style: GoogleFonts.roboto(fontSize: 18))),
            )
          ],
        ),
      ),
    );
  }
}
