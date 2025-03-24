import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;


class GuardProfilePage extends StatefulWidget {
  final String? email;
  const GuardProfilePage({super.key, required this.email});
  @override
  _GuardProfilePageState createState() => _GuardProfilePageState();
}

class _GuardProfilePageState extends State<GuardProfilePage> {
  var user = UserPreferences.myGuardUser;

  late String imagePath;

  late final TextEditingController controller_location;

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    databaseInterface db = databaseInterface();
    GuardUser result = await db.get_guard_by_email(currEmail);
    print("result obj image path${result.imagePath}");

    setState(() {
      user = result;
      controller_location.text = user.location;
      imagePath = user.imagePath;
      print("Result Name in Profile Page${result.name}");
    });

    setState(() {
      pic = NetworkImage(imagePath);
    });
  }

  @override
  void initState() {
    super.initState();
    // String? curr_email = LoggedInDetails.getEmail();
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    controller_location = TextEditingController();

    imagePath = UserPreferences.myGuardUser.imagePath;
    pic = NetworkImage(imagePath);
    imagePicker = ImagePicker();

    init();
    print("User Name in Profile Page${user.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
            255, 180, 180, 180), // Set the background color
        centerTitle: true, // Center-align the title
        iconTheme: const IconThemeData(
            color: Colors.black), // Set the back arrow color
        flexibleSpace: Container(
          color: hexToColor(guardColors[0]),
        ),
        title: const Text(
          "Guard Profile Page",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ), // Replace "Your Title" with your desired title
      ),
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 243, 240, 244),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            ImageWidget(),
            const SizedBox(height: 24),
            buildName(user),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            builText(controller_location, "Location Allocated", false, 1),
          ],
        ),
      ),
    );
  }

  Widget buildName(GuardUser user) => Column(
        children: [
          Text(
            user.name,
            style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Color(int.parse("0xFF344953"))),
          ),
          // const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Color(int.parse("0xFF304053")).withOpacity(0.6)),
          )
        ],
      );

  Widget builText(TextEditingController controller, String label,
          final bool enabled, int maxLines) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(int.parse("0xFF344953"))),
          ),
          const SizedBox(height: 8),
          TextField(
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.grey[800],
            ),
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(
                color: Color(int.parse("0xFF344953")),
              ),
            ),
            maxLines: maxLines,
          ),
        ],
      );

  Future<void> pick_image() async {
    var source = ImageSource.gallery;
    XFile image = await imagePicker.pickImage(source: source);

    var widgetEmail = widget.email;
    if (widgetEmail != null) {
      await databaseInterface.send_image(
          image, "/guards/change_profile_picture_of_guard", widgetEmail);
    }

    databaseInterface db = databaseInterface();
    GuardUser result = await db.get_guard_by_email(widgetEmail);

    var picLocal = NetworkImage(result.imagePath);
    setState(() {
      pic = picLocal;
    });
  }

  Future<void> pick_image_blank() async {
    var source = ImageSource.gallery;
    var filePath =
       image_paths.dummy_person; // Replace with the actual file path
    XFile image = XFile(filePath);

    var widgetEmail = widget.email;
    if (widgetEmail != null) {
      await databaseInterface.send_image(
          image, "/guards/change_profile_picture_of_guard", widgetEmail);
    }

    databaseInterface db = databaseInterface();
    GuardUser result = await db.get_guard_by_email(widgetEmail);

    var picLocal = NetworkImage(result.imagePath);
    setState(() {
      pic = picLocal;
    });
  }

  Widget ImageWidget() {
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Material(
              color: Colors.transparent,
              child: Ink.image(
                // image: AssetImage(image),
                // image: NetworkImage(widget.imagePath),
                image: pic,
                fit: BoxFit.cover,
                width: 180,
                height: 180,
                child: InkWell(onTap: () async {
                  // pick_image();
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
