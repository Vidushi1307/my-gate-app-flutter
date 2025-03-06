import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Description extends StatelessWidget {
  const Description({super.key, required this.title, required this.description});
  final String title, description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Description')),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                title,
                style: GoogleFonts.roboto(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                description,
                style: GoogleFonts.roboto(
                    fontSize: 18, ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
