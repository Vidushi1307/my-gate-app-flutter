import 'package:flutter/material.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  bool showFullDetails = false;

  final String briefIntro =
      'InSight automates and simplifies lab entry/exit for CS block at IIT Ropar, '
      'offering real-time tracking and efficient lab monitoring.';

  final String fullIntro =
      'Our app InSight is designed to automate and streamline the process of student entry and exit in the Computer Science block labs at IIT Ropar. '
      'By eliminating manual tracking methods like physical registers, InSight enables a more secure, efficient, and transparent system for monitoring lab usage. '
      'The application logs each student\'s entry and exit time automatically using smart authentication, and provides real-time data to lab guards, faculty advisors, and administrators.\n\n'
      'InSight not only ensures proper utilization of lab infrastructure but also assists in generating comprehensive lab usage statistics. '
      'Admins and authorized staff can view active lab sessions, analyze lab occupancy trends, and even force-exit students if needed. '
      'With features like time-based filtering, visual dashboards, and batch-wise utilization insights, InSight helps improve accountability and optimize resource allocation in academic labs. '
      'This app was developed as a part of our academic project to address real-world challenges in campus operations.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                image_paths.iit_ropar,
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'About InSight',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                briefIntro,
                style: const TextStyle(fontSize: 16,color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    showFullDetails = !showFullDetails;
                  });
                },
                child: Text(
                  showFullDetails ? 'Hide Details' : 'More Details',
                  style: const TextStyle(fontSize: 16,color: Colors.blue),
                ),
              ),
              if (showFullDetails)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fullIntro,
                    style: const TextStyle(fontSize: 15,color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                ),
              const SizedBox(height: 24.0),
              const Text(
                'Contributors:\n\n'
                'Primary Developers:\n'
                'Vidushi Goyal (2022CSB1142), Thekkepat Sankalp Shashi (2022CSB1137)\n\n'

                'Mentor and Coordinator: Dr. Puneet Goyal (IIT Ropar)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
