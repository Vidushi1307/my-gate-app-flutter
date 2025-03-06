import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

class ProfilePage extends StatefulWidget {
  final String? email;
  final bool isEditable;
  const ProfilePage({super.key, required this.email, required this.isEditable});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool editAccess = true;
  var user = UserPreferences.myUser;

  late String imagePath;

  late final TextEditingController controller_phone;
  late final TextEditingController controller_department;
  late final TextEditingController controller_year_of_entry;
  late final TextEditingController controller_degree;
  late final TextEditingController controller_gender;

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    databaseInterface db = databaseInterface();
    User result = await db.get_student_by_email(currEmail);
    // print("result obj image path" + result.imagePath);
    setState(() {
      user = result;
      controller_phone.text = result.phone;
      controller_department.text = result.department;
      controller_year_of_entry.text = result.year_of_entry;
      controller_degree.text = result.degree;
      controller_gender.text = result.gender;
      /* controller_gender.text=result. */
      print("Gender in yo:${result.gender}");
      // imagePath = result.imagePath;
      print("image path inside setstate: $imagePath");
    });

    setState(() {
      pic = result.profileImage;
    });
    /* print("Gender in yo:"+controller_gender.text); */
  }

  @override
  void initState() {
    super.initState();
    controller_phone = TextEditingController();
    controller_department = TextEditingController();
    controller_year_of_entry = TextEditingController();
    controller_degree = TextEditingController();
    controller_gender = TextEditingController();

    imagePath = UserPreferences.myUser.imagePath;
    pic = NetworkImage(imagePath);
    imagePicker = ImagePicker();
    // print("image path in image widget: " + this.imagePath);
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: Colors.white,
      // backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color to black
        centerTitle: true, // Center-align the title
        iconTheme: const IconThemeData(
            color: Color.fromARGB(
                221, 255, 255, 255)), // Set the back arrow color to white
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Profile Page",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold), // Set the text color to white
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 232, 232, 234),
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
            builText_phone(controller_phone, "Phone", widget.isEditable, 1),
            const SizedBox(height: 24),
            builText(controller_department, "Department", false, 1),
            const SizedBox(height: 24),
            builText(controller_degree, "Degree", false, 1),
            const SizedBox(height: 24),
            builText(controller_year_of_entry, "Year of Entry", false, 1),
            const SizedBox(height: 24),
            builText(controller_gender, "Gender", false, 1),
            const SizedBox(height: 24),
            /* ElevatedButton(
              onPressed: (){},
              child:Text('Edit '),
            ), */
          ],
        ),
      ),
    );
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.name,
            style:  GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
                color: Colors.black.withOpacity(0.7)
            ),
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
            style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.black),
            enabled: enabled,
            controller: controller,

            decoration: InputDecoration(

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

  Widget builText_phone(TextEditingController controller, String label,
          bool enabled, int maxLines) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.black),
                      enabled: enabled, // Use the 'enabled' parameter here
                      controller: controller,
                      decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: TextStyle(
                          color: Color(int.parse("0xFF344953")),
                        ),
                      ),
                      maxLines: maxLines,
                    ),
                    if (enabled) // Only show the edit button if enabled is true
                      Positioned(
                        right: 0,
                        top: 10,
                        child: TextButton(
                          onPressed: () async {
                            // Handle button press here
                            await databaseInterface
                                .update_number(controller.text, user.email)
                                .then((res) => {
                                      if (res == true)
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(get_snack_bar(
                                                  "Phone number updated",
                                                  Colors.green))
                                        }
                                      else
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(get_snack_bar(
                                                  "Failed to Update Phone Number",
                                                  Colors.red))
                                        }
                                    });
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
        ],
      );

  Future<void> pick_image() async {
    print("edit profile page image clicked 2");
    var source = ImageSource.gallery;
    print(source);
    XFile image = await imagePicker.pickImage(source: source);
    var widgetEmail = widget.email;
    print("image is picked");
    print(image.path);
    if (widgetEmail != null) {
      await databaseInterface.send_image(
          image, "/students/change_profile_picture_of_student", widgetEmail);
    }

    databaseInterface db = databaseInterface();
    User result = await db.get_student_by_email(widget.email);

    var picLocal = result.profileImage;
    setState(() {
      pic = picLocal;
    });
  }

  Future<void> pick_image_blank() async {
    var source = ImageSource.gallery;
    print(source);
    var filePath =
        "assets/images/dummy_person.jpg"; // Replace with the actual file path
    XFile image = XFile(filePath);
    var widgetEmail = widget.email;
    if (widgetEmail != null) {
      await databaseInterface.send_image(
          image, "/students/change_profile_picture_of_student", widgetEmail);
    }

    databaseInterface db = databaseInterface();
    User result = await db.get_student_by_email(widget.email);

    var picLocal = NetworkImage(result.imagePath);
    var removeImage = const AssetImage('images/dummy_person.jpg');
    setState(() {
      pic = removeImage;
    });
  }

  Widget ImageWidget() {
    print("edit 1");
    return ViewProfilePage();
    /* if(widget.isEditable){
      print("edit 2");
      /* return EditableProfilePage(); */
    } */
    /* return ViewProfilePage(); */
  }

  Widget EditableProfilePage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: Ink.image(
                  // image: AssetImage(image),
                  // image: NetworkImage(widget.imagePath),
                  image: pic,
                  fit: BoxFit.cover,
                  width: 180,
                  height: 180,
                  child: InkWell(
                    onTap: () async {
                      pick_image();
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            // child: buildEditIcon(Theme.of(context).colorScheme.primary),
            child: buildEditIcon(Color(int.parse("0xFF344953"))),
          ),
          /* Positioned(
          bottom:0,
          right: 50,
          child: buildEditIcon_1(Color(int.parse("0xFF344953"))),
        ), */
        ],
      ),
    );
  }

  Widget ViewProfilePage() {
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Material(
              color: Colors.transparent,
              // color: Colors.blue,
              child: Ink.image(
                // image: AssetImage(image),
                // image: NetworkImage(widget.imagePath),
                image: pic,
                fit: BoxFit.cover,
                width: 180,
                height: 180,
              ),
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 4,
          //   // child: buildEditIcon(Theme.of(context).colorScheme.primary),
          //   child: buildEditIcon(Color(int.parse("0xFF344953"))),
          // ),
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

  Widget buildEditIcon_1(Color color) => buildCircle(
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
