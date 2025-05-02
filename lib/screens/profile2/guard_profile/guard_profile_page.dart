import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/screens/guard/enter_exit.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/screens/student/home_student.dart';
import 'package:my_gate_app/get_email.dart';

class GuardProfilePage extends StatefulWidget {
  final String? email;
  final GuardUser guard;
  final String type;

  const GuardProfilePage({super.key, required this.email, required this.guard, required this.type});
  @override
  _GuardProfilePageState createState() => _GuardProfilePageState();
}

class _GuardProfilePageState extends State<GuardProfilePage> {
  bool editAccess = true;
  bool _isEditing = false;

  XFile? _pickedFile; // For storing the picked image
  bool _isUploading = false;
  var user = UserPreferences.myGuardUser;

  late String imagePath;

  late final TextEditingController controller_phone;
  late final TextEditingController controller_department;
  late final TextEditingController controller_year_of_entry;
  late final TextEditingController controller_degree;
  late final TextEditingController controller_gender;
  late final TextEditingController controller_entry_no;
  final TextEditingController _nameController = TextEditingController();

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? currEmail = widget.email;
    GuardUser result = widget.guard;
    setState(() {
      user = result;
//      controller_phone.text = result.phone;
//      controller_department.text = result.department;
//      controller_year_of_entry.text = result.year_of_entry;
//      controller_degree.text = result.degree;
//      controller_gender.text = result.gender;
//      controller_entry_no.text = result.entry_no ?? "Loading...";
    });

    setState(() {
      pic = result.profileImage;
    });
  }

  @override
  void initState() {
    super.initState();
    controller_phone = TextEditingController();
    controller_department = TextEditingController();
    controller_year_of_entry = TextEditingController();
    controller_degree = TextEditingController();
    controller_gender = TextEditingController();
    controller_entry_no = TextEditingController();
    _nameController.text = user.name;

    imagePath = UserPreferences.myUser.imagePath;
    pic = NetworkImage(imagePath);
    imagePicker = ImagePicker();
    init();
  }

  // Updated row builder with horizontal scrolling and compact spacing
  Widget _buildProfileSection(String label, String value) {
    return Container(
      /* decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),*/
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.mPlusRounded1c(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Simplified divider row
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: Colors.white,
        thickness: 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 89, 190),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 89, 190),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Column(
        children: [
          // Top section with profile image

          // White container that extends to bottom
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(children: [
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      ImageWidget(),
                      const SizedBox(height: 24),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileSection("Name",
                            _isEditing ? _nameController.text : user.name),
                        _buildDivider(),
                        _buildProfileSection("Email", user.email),
                        _buildDivider(),
                        _buildProfileSection(
                            "Entry No", "N/A"),
                        _buildDivider(),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Store navigator references BEFORE async operations
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final mainNavigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Deleting account..."),
            ],
          ),
        ),
      ),
    );

    try {
      print("Sending delete request");
      await databaseInterface.delete_authority(LoggedInDetails.getEmail());
      LoggedInDetails.setEmail('');
      // Execute navigation in next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("Dismissing dialog and navigating");
        rootNavigator.pop(); // Dismiss dialog
        mainNavigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("Handling error: $e");
        if (rootNavigator.canPop()) rootNavigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    }
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 89, 190),
          borderRadius: BorderRadius.circular(25),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Select
            IconButton(
              icon: Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: 40,
              ),
              onPressed: _pickImage,
            ),

            // Home Button
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 40),
              onPressed: () {
//                Navigator.pushReplacement(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) =>
//                          EntryExit(guard_location: "CS Block")),
//                );
                  Navigator.pop(context);
              },
            ),

            // Delete Button
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 40),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                          'Are you sure you want to permanently delete your account? '
                          'This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // No button
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _deleteAccount(
                                context); // Call your delete function
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                                color:
                                    Colors.red), // Make "Yes" red for emphasis
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          _isUploading = true;
        });

        // Convert XFile to File if your backend requires it
        final File imageFile = File(pickedFile.path);
        await _uploadProfileImage(imageFile, widget.type);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection failed: ${e.toString()}')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget ImageWidget() {
    ImageProvider backgroundImg;

    if (_pickedFile != null) {
      // 1. Local file picked but not yet uploaded
      backgroundImg = FileImage(File(_pickedFile!.path));
    } else if (pic != null) {
      // 2. Base64 image from server
      backgroundImg = pic!;
    } else {
      // 3. Fallback dummy image
      backgroundImg = AssetImage(image_paths.dummy_person);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 90,
          backgroundImage: backgroundImg,
        ),
        if (_isUploading)
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Future<void> _uploadProfileImage(File image, String type) async {
    try {
      //     final success = true;
      final success = await databaseInterface().uploadProfileImage(
        image,
        user.email,
        type,
      );

      if (success) {
        if (type  == "Guard") {
        // Refresh user data
          final updatedUser =
              await databaseInterface().get_guard_by_email(user.email);
          setState(() => user = updatedUser);
        }
        else {
          final result =
              await databaseInterface().get_authority_by_email(user.email);
              GuardUser authority_converted_to_guard = GuardUser(
                profileImage: result.profileImage,
                imagePath: result.imagePath,
                name: result.name,
                email: result.email,
                location: result.designation,
                isDarkMode: true,
              );
          setState(() => user = authority_converted_to_guard);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')));
    }
  }

  Future<void> pick_image_blank() async {
    var source = ImageSource.gallery;
    print(source);
    var filePath =
        image_paths.dummy_person; // Replace with the actual file path
    XFile image = XFile(filePath);
    var widgetEmail = widget.email;
    if (widgetEmail != null) {
      await databaseInterface.send_image(
          image, "/students/change_profile_picture_of_student", widgetEmail);
    }

    GuardUser result = await databaseInterface().get_guard_by_email(widget.email);

    var picLocal = NetworkImage(result.imagePath);
    var removeImage = const AssetImage(image_paths.dummy_person);
    setState(() {
      pic = removeImage;
    });
  }

  Widget ViewProfilePage() {
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Material(
              color: Colors.black,
              child: Ink.image(
                image: pic,
                fit: BoxFit.cover,
                width: 180,
                height: 180,
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

  @override
  void dispose() {
    // Dispose all your controllers:
    controller_phone.dispose();
    controller_department.dispose();
    controller_year_of_entry.dispose();
    controller_degree.dispose();
    controller_gender.dispose();
    controller_entry_no.dispose();

    // Also dispose the name controller if you added it:
    _nameController?.dispose(); // The ? is optional but safe

    // Don't forget to call super.dispose()
    super.dispose();
  }
}
