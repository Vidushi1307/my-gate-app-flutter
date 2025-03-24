import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/profile2/widget/appbar_widget.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

class AuthorityProfilePage extends StatefulWidget {
  final String? email;
  const AuthorityProfilePage({super.key, required this.email});
  @override
  _AuthorityProfilePageState createState() => _AuthorityProfilePageState();
}

class _AuthorityProfilePageState extends State<AuthorityProfilePage> {
  var user = UserPreferences.myAuthorityUser;

  late final TextEditingController controller_designation;

  late String imagePath;
  var imagePicker;
  var pic;

  Future<void> init() async {
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    databaseInterface db = databaseInterface();
    AuthorityUser result = await db.get_authority_by_email(currEmail);
    setState(() {
      user = result;
      controller_designation.text = user.designation;
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
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    controller_designation = TextEditingController();

    imagePath = UserPreferences.myAuthorityUser.imagePath;
    pic = NetworkImage(imagePath);
    imagePicker = ImagePicker();

    init();
    print("User Name in Profile Page${user.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* backgroundColor: Colors.white, */
      appBar: buildAppBar(context),
      body: Container(
        padding: const EdgeInsets.only(top: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          physics: const BouncingScrollPhysics(),
          children: [
            ImageWidget(),
            const SizedBox(height: 24),
            buildName(user),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            builText(controller_designation, "Designation", false, 1),
          ],
        ),
      ),
    );
  }

  Widget buildName(AuthorityUser user) => Column(
        children: [
          Text(
            user.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
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
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: enabled,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Roboto', // Change the font family as needed
              fontSize: 16.0, // Adjust the font size as needed
            ),
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200], // Set the background color
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0), // Adjust the padding as needed
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust the border radius as needed
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 36, 0, 108),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust the border radius as needed
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust the border radius as needed
              ),
            ),
            maxLines: maxLines,
          ),
        ],
      );

  Future<void> pick_image() async {
    print("edit profile page image clicked 2");
    var source = ImageSource.gallery;
    XFile image = await imagePicker.pickImage(source: source);
    var widgetEmail = widget.email;
    if (widgetEmail != null) {
      await databaseInterface.send_image(image,
          "/authorities/change_profile_picture_of_authority", widgetEmail);
    }
    databaseInterface db = databaseInterface();
    AuthorityUser result = await db.get_authority_by_email(widget.email);
    var picLocal = NetworkImage(result.imagePath);
    setState(() {
      pic = picLocal;
    });
  }

  Future<void> pick_image_blank() async {
    print("edit profile page image clicked 2");
    var source = ImageSource.gallery;
    var filePath = image_paths.dummy_person;
    XFile image = XFile(filePath);
    var widgetEmail = widget.email;
    if (widgetEmail != null) {
      await databaseInterface.send_image(image,
          "/authorities/change_profile_picture_of_authority", widgetEmail);
    }
    databaseInterface db = databaseInterface();
    AuthorityUser result = await db.get_authority_by_email(widget.email);
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
